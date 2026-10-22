//
//  RxRealmListTests.swift
//  RxRealm
//
//  Created by Marin Todorov on 5/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RealmSwift
import RxRealm
import RxSwift

class RxRealmListTests: XCTestCase {
  let allTests = [
    "testListType": testListType,
    "testListTypeChangeset": testListTypeChangeset
  ]
  func testListType() {
    let realm = realmInMemory(#function)

    let message = Message("first")
    try! realm.write {
      realm.add(message)
    }

    let users = Observable.collection(from: message.recipients)
      .skip(1)
      .map { $0.count }

    DispatchQueue.main.async {
      try! realm.write {
        message.recipients.append(User("user1"))
      }
    }

    XCTAssertEqual(try users.toBlocking(timeout: testTimeout).first()!, 1)

    let backgroundWrite = {
      let realm = realmInMemory(#function)
      let message = realm.objects(Message.self).first!
      try! realm.write {
        message.recipients.remove(at: 0)
      }
    }

    XCTAssertEqual(try users.onSubscribeInBackground(backgroundWrite).toBlocking(timeout: testTimeout).first()!, 0)
  }

  func testListTypeChangeset() {
    let realm = realmInMemory(#function)

    let message = Message("first")
    try! realm.write {
      realm.add(message)
    }

    let users = Observable.changeset(from: message.recipients)
      .map(stringifyChanges)

    XCTAssertEqual(try users.toBlocking(timeout: testTimeout).first()!, "count:0")

    DispatchQueue.main.async {
      try! realm.write {
        message.recipients.append(User("user1"))
      }
    }

    XCTAssertEqual(try users.skip(1).toBlocking(timeout: testTimeout).first()!, "count:1 inserted:[0] deleted:[] updated:[]")

    let backgroundWrite = {
      let realm = realmInMemory(#function)
      let message = realm.objects(Message.self).first!
      try! realm.write {
        message.recipients.remove(at: 0)
      }
    }

    XCTAssertTrue(changesetOrCoalesced("count:0 inserted:[] deleted:[0] updated:[]").contains(try users.skip(1).onSubscribeInBackground(backgroundWrite).toBlocking(timeout: testTimeout).first()!))
  }
}
