//
//  RxRealmObjectTests.swift
//  RxRealm
//
//  Created by Marin Todorov on 10/31/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RxSwift
import RealmSwift
import RxRealm
import RxTest

class RxRealmObjectTests: XCTestCase {

    fileprivate func realmInMemory(_ name: String) -> Realm {
        var conf = Realm.Configuration()
        conf.inMemoryIdentifier = name
        return try! Realm(configuration: conf)
    }

    func testObjectChangeNotifications() {
        let expectation1 = expectation(description: "Object change")

        let realm = realmInMemory(#function)
        let bag = DisposeBag()

        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)

        //create object
        let idValue = 1024
        let obj = UniqueObject(idValue)
        try! realm.write {
            realm.add(obj)
        }

        let object$ = Observable<UniqueObject>.from(obj).shareReplay(1)
        object$.scan(0, accumulator: {acc, _ in return acc+1})
            .filter { $0 == 4 }.map {_ in ()}
            .subscribe(onNext: expectation1.fulfill, onError: {error in expectation1.fulfill()})
            .addDisposableTo(bag)
        object$
            .map({ object in
                return "name:\(object.name)"
            })
            .subscribe(observer).addDisposableTo(bag)

        scheduler.start()

        //interact with local object instance
        delay(0.1) { //use delay to allow for initial notification
            try! realm.write {
                obj.name = "test1"
            }
        }

        //update object from different thread
        delay(0.2) {
            DispatchQueue.global().async {[unowned self] in
                let realm = self.realmInMemory(#function)
                try! realm.write {
                    realm.objects(UniqueObject.self).filter("id == %@", idValue).first?.name = "test2"
                }
            }
        }

        delay(0.3) {
            try! realm.write {
                realm.delete(obj)
            }
        }

        waitForExpectations(timeout: 5) {error in
            XCTAssertTrue(error == nil)
            XCTAssertEqual(observer.events.count, 4)
            XCTAssertEqual(observer.events[0].value.element, "name:")
            XCTAssertEqual(observer.events[1].value.element, "name:test1")
            XCTAssertEqual(observer.events[2].value.element, "name:test2")
            XCTAssertNotNil(observer.events[3].value.error as? RxRealmError)
            XCTAssertEqual(observer.events[3].value.error as! RxRealmError , RxRealmError.objectDeleted)
        }
    }

}
