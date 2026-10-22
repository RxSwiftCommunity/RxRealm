//
//  RxRealmSynchronousStartTests.swift
//  RxRealm
//

import XCTest

import RealmSwift
import RxRealm
import RxSwift

/// With `synchronousStart`, the current collection is emitted on subscribe and Realm's
/// `.initial` notification is skipped as a duplicate. A write committed on another thread
/// after subscribing but before `.initial` is delivered is folded into `.initial` with no
/// `.update` following it, so skipping `.initial` loses that write.
/// See https://github.com/RxSwiftCommunity/RxRealm/issues/74
///
/// The window is a race against Realm's notifier thread, so each test repeats the
/// sequence that exposed it in `RxRealmLinkingObjectsTests`.
class RxRealmSynchronousStartTests: XCTestCase {
  private let attempts = 50

  private func assertNoWriteIsLost<E>(_ makeObservable: @escaping (LinkingObjects<User>) -> Observable<E>,
                                      count: @escaping (E) -> Int) {
    for attempt in 0 ..< attempts {
      let name = "\(#function)-\(attempt)-\(UUID().uuidString)"
      let realm = realmInMemory(name)
      let message = Message("first")
      try! realm.write {
        realm.add(message)
      }
      let mentions = { makeObservable(message.mentions).map(count) }

      let user = User("user")
      user.lastMessage = message
      DispatchQueue.main.async {
        try! realm.write {
          realm.add(user)
        }
      }
      guard (try? mentions().filter { $0 == 1 }.toBlocking(timeout: testTimeout).first()) != nil else {
        XCTFail("Main thread write was never emitted (attempt \(attempt + 1))")
        return
      }

      let deleteUser = {
        let realm = realmInMemory(name)
        try! realm.write {
          realm.delete(realm.objects(User.self))
        }
      }
      guard (try? mentions().onSubscribeInBackground(deleteUser).filter { $0 == 0 }.toBlocking(timeout: testTimeout).first()) != nil else {
        XCTFail("Write from another thread right after subscribing was never emitted (attempt \(attempt + 1) of \(attempts))")
        return
      }
    }
  }

  func testCollectionDoesNotLoseWriteCommittedBeforeInitialNotification() {
    assertNoWriteIsLost({ Observable.collection(from: $0) }, count: { $0.count })
  }

  func testChangesetDoesNotLoseWriteCommittedBeforeInitialNotification() {
    assertNoWriteIsLost({ Observable.changeset(from: $0) }, count: { $0.0.count })
  }
}
