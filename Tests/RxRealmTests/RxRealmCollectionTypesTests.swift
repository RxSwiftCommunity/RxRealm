//
//  RxRealmCollectionTypesTests.swift
//  RxRealm
//

import XCTest

import RealmSwift
import RxRealm
import RxSwift

/// Each collection type RxRealm supports, through the array and changeset observables.
class RxRealmCollectionTypesTests: XCTestCase {
  private func makeMessageWithRecipient(_ name: String) -> (Realm, Message) {
    let realm = realmInMemory(name)
    let message = Message("first")
    let user = User("user")
    user.lastMessage = message
    message.recipients.append(user)
    try! realm.write {
      realm.add(message)
    }
    return (realm, message)
  }

  func testArrayFromList() throws {
    let (_, message) = makeMessageWithRecipient(#function)
    let names = try Observable.array(from: message.recipients).toBlocking(timeout: testTimeout).first()
    XCTAssertEqual(names?.map { $0.name }, ["user"])
  }

  func testArrayFromLinkingObjects() throws {
    let (_, message) = makeMessageWithRecipient(#function)
    let names = try Observable.array(from: message.mentions).toBlocking(timeout: testTimeout).first()
    XCTAssertEqual(names?.map { $0.name }, ["user"])
  }

  func testArrayFromAnyRealmCollection() throws {
    let (realm, _) = makeMessageWithRecipient(#function)
    let users = AnyRealmCollection(realm.objects(User.self))
    let names = try Observable.array(from: users).toBlocking(timeout: testTimeout).first()
    XCTAssertEqual(names?.map { $0.name }, ["user"])
  }

  func testChangesetFromAnyRealmCollection() throws {
    let (realm, _) = makeMessageWithRecipient(#function)
    let users = AnyRealmCollection(realm.objects(User.self))
    let changes = Observable.changeset(from: users).map(stringifyChanges)

    XCTAssertEqual(try changes.toBlocking(timeout: testTimeout).first(), "count:1")

    DispatchQueue.main.async {
      try! realm.write {
        realm.add(User("second"))
      }
    }
    XCTAssertEqual(try changes.skip(1).toBlocking(timeout: testTimeout).first(), "count:2 inserted:[1] deleted:[] updated:[]")
  }

  func testArrayWithChangesetFromList() throws {
    let (realm, message) = makeMessageWithRecipient(#function)
    let changes = Observable.arrayWithChangeset(from: message.recipients)
      .map { "\($0.0.map { $0.name }) \($0.1.map { "inserted:\($0.inserted)" } ?? "initial")" }

    XCTAssertEqual(try changes.toBlocking(timeout: testTimeout).first(), "[\"user\"] initial")

    DispatchQueue.main.async {
      try! realm.write {
        message.recipients.append(User("second"))
      }
    }
    XCTAssertEqual(try changes.skip(1).toBlocking(timeout: testTimeout).first(), "[\"user\", \"second\"] inserted:[1]")
  }
}
