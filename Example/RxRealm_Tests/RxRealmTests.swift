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
    
    var bag: DisposeBag! = DisposeBag()
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "MemoryRealm"
    }
    
    override func tearDown() {
        bag = nil
        super.tearDown()
    }

    private func clearRealm(realm: Realm) {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    private func addObject(realm: Realm, text: String) {
        try! realm.write {
            realm.add(Message(text))
        }
    }
    
    func testEmittedResultsValues() {
        let expectation1 = expectationWithDescription("Results<Message> first")
        let expectation2 = expectationWithDescription("Results<Message> second")
        
        let realm = try! Realm()
        clearRealm(realm)
        
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

        addObject(realm, text: "first")
        
        performSelector(#selector(addSecondMessage), withObject: nil, afterDelay: 0.1)
        
        scheduler.start()
        
        waitForExpectationsWithTimeout(0.5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 2)
            let results = observer.events.last!.value.element!
            XCTAssertTrue(results.first! == Message("first"))
            XCTAssertTrue(results.last! == Message("second"))
        }
    }
    
    func testEmittedArrayValues() {
        let expectation1 = expectationWithDescription("Array<Message> first")
        let expectation2 = expectationWithDescription("Array<Message> second")
        
        let realm = try! Realm()
        clearRealm(realm)
        
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
        
        addObject(realm, text: "first")

        performSelector(#selector(addSecondMessage), withObject: nil, afterDelay: 0.1)

        scheduler.start()
        
        waitForExpectationsWithTimeout(0.5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 2)
            XCTAssertTrue(observer.events.first!.value.element! == [Message("first")])
            XCTAssertTrue(observer.events.last!.value.element! == [Message("first"), Message("second")])
        }
    }
    
    func addSecondMessage() {
        addObject(try! Realm(), text: "second")
    }
}