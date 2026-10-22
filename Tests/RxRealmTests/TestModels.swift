//
//  TestModels.swift
//  RxRealm
//
//  Created by Marin Todorov on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

/// Upper bound for `toBlocking` waits, so a missing notification fails the test instead of hanging the run.
let testTimeout: TimeInterval = 10

extension ObservableType {
  /// Runs `work` on a background queue once this observable is subscribed, so a write
  /// meant to trigger the next element can't land before the subscription observing it.
  func onSubscribeInBackground(_ work: @escaping () -> Void) -> Observable<Element> {
    return self.do(onSubscribed: {
      DispatchQueue.global(qos: .userInitiated).async(execute: work)
    })
  }
}

/// Runs the current run loop until `condition` holds or `testTimeout` passes.
@discardableResult
func runRunLoop(until condition: () -> Bool) -> Bool {
  let deadline = Date().addingTimeInterval(testTimeout)
  while !condition() && Date() < deadline {
    RunLoop.current.run(until: Date().addingTimeInterval(0.01))
  }
  return condition()
}

/// Performs `write` and runs the run loop until an unfiltered observer of all `T` objects has
/// been notified of it. Notifications for the same Realm are delivered together, so a filtered
/// observer that stayed quiet by then really skipped the change.
///
/// The barrier observes its own `Results`: an unfiltered observer on the same `Results` instance
/// as a key path filtered one makes Realm report every change to both.
func writeAndWaitForDelivery<T: Object>(_ realm: Realm, _ type: T.Type, _ write: () -> Void) -> Bool {
  var initialDelivered = false
  var updateDelivered = false
  let token = realm.objects(type).observe { change in
    switch change {
    case .initial: initialDelivered = true
    case .update: updateDelivered = true
    case .error: break
    }
  }
  defer { token.invalidate() }
  guard runRunLoop(until: { initialDelivered }) else { return false }
  write()
  return runRunLoop(until: { updateDelivered })
}

func realmInMemory(_ name: String = UUID().uuidString) -> Realm {
  var conf = Realm.Configuration()
  conf.inMemoryIdentifier = name
  return try! Realm(configuration: conf)
}

/// The strings a write from another thread can produce: its indexed changeset, or just the
/// count when Realm coalesces the write into the initial notification, which has no changeset.
func changesetOrCoalesced(_ changeset: String) -> [String] {
  return [changeset, String(changeset.prefix { $0 != " " })]
}

func stringifyChanges<E>(_ arg: (AnyRealmCollection<E>, RealmChangeset?)) -> String {
  let (result, changes) = arg
  if let changes = changes {
    return "count:\(result.count) inserted:\(changes.inserted) deleted:\(changes.deleted) updated:\(changes.updated)"
  } else {
    return "count:\(result.count)"
  }
}

// MARK: Message
class Message: Object {
  @objc dynamic var text = ""

  let recipients = List<User>()
  let mentions = LinkingObjects(fromType: User.self, property: "lastMessage")

  convenience init(_ text: String) {
    self.init()
    self.text = text
  }
}

// MARK: User
class User: Object {
  @objc dynamic var name = ""
  @objc dynamic var lastMessage: Message?

  convenience init(_ name: String) {
    self.init()
    self.name = name
  }
}

// MARK: UniqueObject
class UniqueObject: Object {
  @objc dynamic var id = 0
  @objc dynamic var name = ""

  convenience init(_ id: Int) {
    self.init()
    self.id = id
  }

  override class func primaryKey() -> String? {
    return "id"
  }
}

// MARK: Dog
class Dog: Object {
  @objc dynamic var name = ""
  @objc dynamic var age = 0

  convenience init(_ name: String) {
    self.init()
    self.name = name
  }
}
