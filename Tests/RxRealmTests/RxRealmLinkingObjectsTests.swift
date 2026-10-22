//
//  RxRealmLinkingObjectsTests.swift
//  RxRealm
//
//  Created by Marin Todorov on 5/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

import RealmSwift
import RxRealm
import RxSwift

class RxRealmLinkingObjectsTests: XCTestCase {
  let allTests = [
    "testLinkingObjectsType": testLinkingObjectsType,
    "testLinkingObjectsTypeChangeset": testLinkingObjectsTypeChangeset
  ]

  func testLinkingObjectsType() {
    let realm = realmInMemory(#function)

    let message = Message("first")
    try! realm.write {
      realm.add(message)
    }

    let users = Observable.collection(from: message.mentions)
      .map { $0.count }

    XCTAssertEqual(try users.toBlocking(timeout: testTimeout).first()!, 0)

    let user1 = User("user1")
    user1.lastMessage = message

    DispatchQueue.main.async {
      try! realm.write {
        realm.add(user1)
      }
    }

    XCTAssertEqual(try users.skip(1).toBlocking(timeout: testTimeout).first()!, 1)

    let backgroundWrite = {
      let realm = realmInMemory(#function)
      let user1 = realm.objects(User.self).first!
      try! realm.write {
        realm.delete(user1)
      }
    }

    XCTAssertEqual(try users.skip(1).onSubscribeInBackground(backgroundWrite).toBlocking(timeout: testTimeout).first()!, 0)
  }

  func testLinkingObjectsTypeChangeset() {
    let realm = realmInMemory(#function)

    let message = Message("first")
    try! realm.write {
      realm.add(message)
    }

    let users = Observable.changeset(from: message.mentions)
      .map(stringifyChanges)

    XCTAssertEqual(try users.toBlocking(timeout: testTimeout).first()!, "count:0")

    let user1 = User("user1")
    user1.lastMessage = message

    DispatchQueue.main.async {
      try! realm.write {
        realm.add(user1)
      }
    }

    XCTAssertEqual(try users.skip(1).toBlocking(timeout: testTimeout).first()!, "count:1 inserted:[0] deleted:[] updated:[]")

    let backgroundWrite = {
      let realm = realmInMemory(#function)
      let user1 = realm.objects(User.self).first!
      try! realm.write {
        realm.delete(user1)
      }
    }

    XCTAssertTrue(changesetOrCoalesced("count:0 inserted:[] deleted:[0] updated:[]").contains(try users.skip(1).onSubscribeInBackground(backgroundWrite).toBlocking(timeout: testTimeout).first()!))
  }
}
