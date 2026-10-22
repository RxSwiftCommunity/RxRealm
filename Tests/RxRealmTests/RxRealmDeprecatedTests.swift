//
//  RxRealmDeprecatedTests.swift
//  RxRealm
//

import XCTest

import RealmSwift
import RxRealm
import RxSwift

/// The deprecated names are still public API until they're removed in a major release,
/// so check that each one still forwards to its replacement.
class RxRealmDeprecatedTests: XCTestCase {
  @available(*, deprecated)
  func testDeprecatedCollectionObservablesForward() throws {
    let realm = realmInMemory(#function)
    try realm.write {
      realm.add(Message("first"))
    }
    let messages = realm.objects(Message.self)

    XCTAssertEqual(try Observable.from(messages).toBlocking(timeout: testTimeout).first()?.count, 1)
    XCTAssertEqual(try Observable.arrayFrom(messages).toBlocking(timeout: testTimeout).first()?.map { $0.text }, ["first"])
    XCTAssertEqual(try Observable.changesetFrom(messages).toBlocking(timeout: testTimeout).first()?.0.count, 1)
    XCTAssertEqual(try Observable.changesetArrayFrom(messages).toBlocking(timeout: testTimeout).first()?.0.map { $0.text }, ["first"])
  }

  @available(*, deprecated)
  func testDeprecatedObjectObservableForwards() throws {
    let realm = realmInMemory(#function)
    let object = UniqueObject(1)
    try realm.write {
      realm.add(object)
    }

    XCTAssertEqual(try Observable.from(object).toBlocking(timeout: testTimeout).first()?.id, 1)
  }

  @available(*, deprecated)
  func testDeprecatedRealmObservableForwards() throws {
    let realm = realmInMemory(#function)
    let notifications = Observable<(Realm, Realm.Notification)>.from(realm)

    DispatchQueue.main.async {
      try! realm.write {
        realm.add(Message("first"))
      }
    }
    XCTAssertEqual(try notifications.toBlocking(timeout: testTimeout).first()?.1, .didChange)
  }
}
