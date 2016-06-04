//
//  RxRealmWriteSinks.swift
//  RxRealm
//
//  Created by Marin Todorov on 6/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import RxTests

class RxRealmWriteSinks: XCTestCase {
    private func realmInMemoryConfiguration(name: String) -> Realm.Configuration {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return conf
    }
    
    private func realmInMemory(name: String) -> Realm {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return try! Realm(configuration: conf)
    }

    func testRxAddObject() {
        let expectation = expectationWithDescription("Message1")
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let events = [
            next(0, Message("1")),
            completed(0)
        ]
        
        let rx_add: AnyObserver<Message> = realm.rx_add()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribeNext {
            switch $0.count {
            case 1:
                expectation.fulfill()
            default:
                break
            }
            }.addDisposableTo(bag)
        
        observable
            .subscribe(rx_add)
            .addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(0.1, handler: nil)
        
        
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events[0].time, 0)
        XCTAssertTrue(observer.events[0].value.element!.equalTo([Message("1")]))
    }
    
    func testRxAddObjects() {
        let expectation = expectationWithDescription("Message1")
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let events = [
            next(0, [Message("1"), Message("2")]),
            completed(0)
        ]
        
        let rx_add: AnyObserver<[Message]> = realm.rx_add()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        
        observable.subscribe(rx_add)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribeNext {
            switch $0.count {
            case 2:
                expectation.fulfill()
            default:
                break
            }
            }.addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(0.1, handler: nil)
        
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events[0].time, 0)
        XCTAssertTrue(observer.events[0].value.element!.equalTo([Message("1"), Message("2")]))
    }
    
    func testRxAddUpdateObjects() {
        let expectation = expectationWithDescription("Message1")
        let realm = realmInMemory(#function)
        let bag = DisposeBag()
        let events = [
            next(0, [UniqueObject(1), UniqueObject(2)]),
            next(1, [UniqueObject(1), UniqueObject(3)]),
            completed(2)
        ]
        
        let rx_add: AnyObserver<[UniqueObject]> = realm.rx_add(update: true)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<UniqueObject>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        let messages$ = realm.objects(UniqueObject).asObservableArray().shareReplay(1)
        
        observable.subscribe(rx_add)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribeNext {
            switch $0.count {
            case 3:
                expectation.fulfill()
            default:
                break
            }
            }.addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(5, handler: {error in
            //check that UniqueObject with id == 1 was overwritten
            XCTAssertTrue(observer.events.last!.value.element!.count == 3)
            XCTAssertTrue(observer.events.last!.value.element![0] == UniqueObject(1))
            XCTAssertTrue(observer.events.last!.value.element![1] == UniqueObject(2))
            XCTAssertTrue(observer.events.last!.value.element![2] == UniqueObject(3))
        })
        
    }

    
    func testRxDeleteItem() {
        let expectation = expectationWithDescription("Message1")
        let realm = realmInMemory(#function)
        let element = Message("1")
        let scheduler = TestScheduler(initialClock: 0)
        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        let rx_delete: AnyObserver<Message> = Realm.rx_delete()
        
        try! realm.write {
            realm.add(element)
        }
        let bag = DisposeBag()
        let events = [
            next(0, element),
            completed(0)
        ]
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        
        observable.subscribe(rx_delete)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribeNext {
            switch $0.count {
            case 0:
                expectation.fulfill()
            default:
                break
            }
            }.addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(0.1, handler: nil)
        
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events[0].time, 0)
        XCTAssertEqual(observer.events[0].value.element!, [Message]())
    }
    
    func testRxDeleteItems() {
        let expectation = expectationWithDescription("Message1")
        let realm = realmInMemory(#function)
        let elements = [Message("1"), Message("1")]
        let scheduler = TestScheduler(initialClock: 0)
        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        let rx_delete: AnyObserver<[Message]> = Realm.rx_delete()
        
        try! realm.write {
            realm.add(elements)
        }
        let bag = DisposeBag()
        let events = [
            next(0, elements),
            completed(0)
        ]
        let observer = scheduler.createObserver(Array<Message>.self)
        let observable = scheduler.createHotObservable(events).asObservable()
        
        observable.subscribe(rx_delete)
            .addDisposableTo(bag)
        
        messages$.subscribe(observer)
            .addDisposableTo(bag)
        
        messages$.subscribeNext {
            switch $0.count {
            case 0:
                expectation.fulfill()
            default:
                break
            }
            }.addDisposableTo(bag)
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(0.1, handler: nil)
        
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events[0].time, 0)
        XCTAssertTrue(observer.events[0].value.element!.isEmpty)
    }
    
    func testRxAddObjectsInBackground() {
        let expectation = expectationWithDescription("All writes successful")
        var conf = Realm.Configuration()
        conf.deleteRealmIfMigrationNeeded = true
        
        let realm = try! Realm(configuration: conf)
        try! realm.write {
            realm.deleteAll()
        }
        
        let bag = DisposeBag()

        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>)
        
        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        
        messages$
            .filter {$0.count == 6}
            .subscribeNext {_ in expectation.fulfill() }
            .addDisposableTo(bag)
        
        messages$
            .subscribe(observer)
            .addDisposableTo(bag)
        
        // subscribe/write on current thread
        [Message("1")].toObservable()
            .subscribe( realm.rx_add() )
            .addDisposableTo(bag)
        
        delayInBackground(0.1, closure: {
            // subscribe/write on background thread
            let realm = try! Realm(configuration: conf)
            [Message("2")].toObservable()
                .subscribe(realm.rx_add() )
                .addDisposableTo(bag)
        })
        
        // subscribe on current/write on main
        [Message("3")].toObservable()
            .observeOn(MainScheduler.instance)
            .subscribe( Realm.rx_add(conf) )
            .addDisposableTo(bag)

        // subscribe on current/write on background
        [Message("4")].toObservable()
            .observeOn( ConcurrentDispatchQueueScheduler(
                queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)))
            .subscribe( Realm.rx_add(conf) )
            .addDisposableTo(bag)

        // subscribe on current/write on background
        [[Message("5"), Message("6")]].toObservable()
            .observeOn( ConcurrentDispatchQueueScheduler(
                queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)))
            .subscribe( Realm.rx_add(conf) )
            .addDisposableTo(bag)

        scheduler.start()
        
        waitForExpectationsWithTimeout(5.0, handler: {error in
            let finalResult = observer.events.last!.value.element!
            XCTAssertTrue(finalResult.count == 6, "The final amount of objects in realm are not correct")
            XCTAssertTrue((try! Realm()).objects(Message).sorted("text")
                .reduce("", combine: { acc, el in acc + el.text
            }) == "123456" /*😈*/, "The final list of objects is not the one expected")
        })
    }
}