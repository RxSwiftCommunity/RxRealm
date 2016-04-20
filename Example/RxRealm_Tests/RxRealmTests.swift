//
//  RxRealm_Tests.swift
//  RxRealm_Tests
//
//  Created by Marin Todorov on 4/21/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
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
    
    func testEmittedArrayValues() {
        let expectation1 = expectationWithDescription("Array<Message> first")
        let expectation2 = expectationWithDescription("Array<Message> second")
        
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Array<Message>)

        let messages$ = realm.objects(Message).asObservableArray().shareReplay(1)
        messages$.subscribeNext {messages in
            if messages.count == 1 && messages.first! == Message("first") {
                expectation1.fulfill()
            }
            if messages.count == 2 && messages.first! == Message("first")
                && messages.last! == Message("second"){
                expectation2.fulfill()
            }
        }.addDisposableTo(bag)
        
        messages$.subscribe(observer).addDisposableTo(bag)
        
        try! realm.write {
            realm.add(Message("first"))
        }

        performSelector(#selector(addSecondMessage), withObject: nil, afterDelay: 0.1)

        scheduler.start()
        
        waitForExpectationsWithTimeout(10) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 2)
        }
    }
    
    func addSecondMessage() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(Message("second"))
        }
    }
}