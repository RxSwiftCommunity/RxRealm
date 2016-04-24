//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//

import XCTest

import RxSwift
import RealmSwift
import RxRealm
import RxTests

func delay(delay: Double, closure: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
                   dispatch_get_main_queue(), closure)
}

class Message: Object, Equatable {
    dynamic var text = ""
    convenience init(_ text: String) {
        self.init()
        self.text = text
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text
}

class RxRealm_Tests: XCTestCase {
    
    private func realmInMemory(name: String) -> Realm {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return try! Realm(configuration: conf)
    }
    
    private func clearRealm(realm: Realm) {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    private func addMessage(realm: Realm, text: String) {
        try! realm.write {
            realm.add(Message(text))
        }
    }
    
    func testEmittedResultsValues() {
        let expectation1 = expectationWithDescription("Results<Message> first")
        let expectation2 = expectationWithDescription("Results<Message> second")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Results<Message>)
        
        let messages$ = realm.objects(Message).asObservable().shareReplay(1)
        messages$.subscribeNext {messages in
            switch messages.count {
            case 1: expectation1.fulfill()
            case 2: expectation2.fulfill()
            default: XCTFail("Unexpected value emitted by Observable")
            }
            }.addDisposableTo(bag)
        
        messages$.subscribe(observer).addDisposableTo(bag)

        addMessage(realm, text: "first(Results)")
        
        delay(0.1) {
            self.addMessage(realm, text: "second(Results)")
        }
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(0.5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 2)
            let results = observer.events.last!.value.element!
            XCTAssertTrue(results.first! == Message("first(Results)"))
            XCTAssertTrue(results.last! == Message("second(Results)"))
        }
    }
    
    func testEmittedArrayValues() {
        let expectation1 = expectationWithDescription("Array<Message> first")
        let expectation2 = expectationWithDescription("Array<Message> second")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>)

        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        messages$.subscribeNext {messages in
            switch messages.count {
            case 1: expectation1.fulfill()
            case 2: expectation2.fulfill()
            default: XCTFail("Unexpected value emitted by Observable")
            }
        }.addDisposableTo(bag)
        
        messages$.subscribe(observer).addDisposableTo(bag)
        
        addMessage(realm, text: "first(Array)")

        delay(0.1) {
            self.addMessage(realm, text: "second(Array)")
        }

        scheduler.start()
        
        waitForExpectationsWithTimeout(0.5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 2)
            XCTAssertTrue(observer.events.first!.value.element! == [Message("first(Array)")])
            XCTAssertTrue(observer.events.last!.value.element! == [Message("first(Array)"), Message("second(Array)")])
        }
    }
    
    func testEmittedChangeset() {
        let expectation1 = expectationWithDescription("did emit all changeset values")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String)

        //initial data
        addMessage(realm, text: "first(Changeset)")

        let messages$ = realm.objects(Message).asObservableChangeset().shareReplay(1)
        messages$.scan(0) { count, _ in
            return count+1
        }
        .filter {$0 == 3}
        .subscribeNext {_ in expectation1.fulfill() }
        .addDisposableTo(bag)
        
        messages$
            .map {result, changes in
                if let changes = changes {
                    return "count:\(result.count) inserted:\(changes.inserted) deleted:\(changes.deleted) updated:\(changes.updated)"
                } else {
                    return "count:\(result.count)"
                }
            }
            .subscribe(observer).addDisposableTo(bag)

        //insert
        delay(0.25) {
            self.addMessage(realm, text: "second(Changeset)")
        }
        //update
        delay(0.5) {
            try! realm.write {
                realm.delete(realm.objects(Message).filter("text='first(Changeset)'").first!)
                realm.objects(Message).filter("text='second(Changeset)'").first!.text = "third(Changeset)"
            }
        }
        //coalesced
        delay(0.7) {
            self.addMessage(realm, text: "first(Changeset)")
        }
        delay(0.7) {
            try! realm.write {
                realm.delete(realm.objects(Message).filter("text='first(Changeset)'").first!)
            }
        }
        
        waitForExpectationsWithTimeout(0.75) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 3)
            XCTAssertEqual(observer.events[0].value.element!, "count:1")
            XCTAssertEqual(observer.events[1].value.element!, "count:2 inserted:[1] deleted:[] updated:[]")
            XCTAssertEqual(observer.events[2].value.element!, "count:1 inserted:[] deleted:[0] updated:[1]")
        }
    }

    func testEmittedArrayChangeset() {
        let expectation1 = expectationWithDescription("did emit all array changeset values")
        
        let realm = realmInMemory(#function)
        clearRealm(realm)
        let bag = DisposeBag()
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String)
        
        //initial data
        addMessage(realm, text: "first(ArrayChangeset)")
        
        let messages$ = realm.objects(Message).asObservableArrayChangeset().shareReplay(1)
        messages$.scan(0) { count, _ in
            return count+1
            }
            .filter {$0 == 3}
            .subscribeNext {_ in expectation1.fulfill() }
            .addDisposableTo(bag)
        
        messages$
            .map {result, changes in
                if let changes = changes {
                    return "count:\(result.count) inserted:\(changes.inserted) deleted:\(changes.deleted) updated:\(changes.updated)"
                } else {
                    return "count:\(result.count)"
                }
            }
            .subscribe(observer).addDisposableTo(bag)
        
        //insert
        delay(0.25) {
            self.addMessage(realm, text: "second(ArrayChangeset)")
        }
        //update
        delay(0.5) {
            try! realm.write {
                realm.delete(realm.objects(Message).filter("text='first(ArrayChangeset)'").first!)
                realm.objects(Message).filter("text='second(ArrayChangeset)'").first!.text = "third(ArrayChangeset)"
            }
        }
        //coalesced
        delay(0.7) {
            self.addMessage(realm, text: "first(ArrayChangeset)")
        }
        delay(0.7) {
            try! realm.write {
                realm.delete(realm.objects(Message).filter("text='first(ArrayChangeset)'").first!)
            }
        }
        
        waitForExpectationsWithTimeout(0.75) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 3)
            XCTAssertEqual(observer.events[0].value.element!, "count:1")
            XCTAssertEqual(observer.events[1].value.element!, "count:2 inserted:[1] deleted:[] updated:[]")
            XCTAssertEqual(observer.events[2].value.element!, "count:1 inserted:[] deleted:[0] updated:[1]")
        }
    }

}