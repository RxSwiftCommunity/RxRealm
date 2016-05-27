//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

/**
 `NotificationEmitter` is a faux protocol to allow for Realm's collections to be handled in a generic way.
 
  All collections already include a `addNotificationBlock(_:)` method - making them conform to `NotificationEmitter` just makes it easier to add Rx methods to them.
 
  The methods of essence in this protocol are `asObservable(...)`, which allow for observing for changes on Realm's collections.
*/
public protocol NotificationEmitter {
    
    /**
     Returns a `NotificationToken`, which while retained enables change notifications for the current collection.
     
     - returns: `NotificationToken` - retain this value to keep notifications being emitted for the current collection.
     */
    func addNotificationBlock(block: (RealmCollectionChange<Self>) -> ()) -> NotificationToken
}

extension List: NotificationEmitter {}
extension AnyRealmCollection: NotificationEmitter {}
extension Results: NotificationEmitter {}
extension LinkingObjects: NotificationEmitter {}

/**
 `RealmChangeset` is a struct that contains the data about a single realm change set. 
 
 It includes the insertions, modifications, and deletions indexes in the data set that the current notification is about.
*/
public struct RealmChangeset {
    /// the indexes in the collection that were deleted
    public let deleted: [Int]
    
    /// the indexes in the collection that were inserted
    public let inserted: [Int]
    
    /// the indexes in the collection that were modified
    public let updated: [Int]

    public init(deleted: [Int], inserted: [Int], updated: [Int]) {
        self.deleted = deleted
        self.inserted = inserted
        self.updated = updated
    }
}

public extension NotificationEmitter where Self: RealmCollectionType {
    
    /**
     Returns an `Observable<Self>` that emits each time the collection data changes. The observable emits an initial value upon subscription.
     
     - returns: `Observable<Self>`, e.g. when called on `Results<Model>` it will return `Observable<Results<Model>>`, on a `List<User>` it will return `Observable<List<User>>`, etc.
     */
    public func asObservable() -> Observable<Self> {
        return Observable.create {observer in
            let token = self.addNotificationBlock {changeset in
                
                let value: Self
                
                switch changeset {
                case .Initial(let latestValue):
                    value = latestValue
                    
                case .Update(let latestValue, _, _, _):
                    value = latestValue
                    
                case .Error(let error):
                    observer.onError(error)
                    return
                }

                observer.onNext(value)
            }
            
            return AnonymousDisposable {
                observer.onCompleted()
                token.stop()
            }
        }
    }
    
    /**
     Returns an `Observable<Array<Self.Generator.Element>>` that emits each time the collection data changes. The observable emits an initial value upon subscription.
     
     This method emits an `Array` containing all the realm collection objects, this means they all live in the memory. If you're using this method to observe large collections you might hit memory warnings.
     
     - returns: `Observable<Array<Self.Generator.Element>>`, e.g. when called on `Results<Model>` it will return `Observable<Array<Model>>`, on a `List<User>` it will return `Observable<Array<User>>`, etc.
     */
    public func asObservableArray() -> Observable<Array<Self.Generator.Element>> {
        return asObservable().map { Array($0) }
    }

    /**
     Returns an `Observable<(Self, RealmChangeset?)>` that emits each time the collection data changes. The observable emits an initial value upon subscription.
     
     When the observable emits for the first time (if the initial notification is not coalesced with an update) the second tuple value will be `nil`.
     
     Each following emit will include a `RealmChangeset` with the indexes inserted, deleted or modified.
     
     - returns: `Observable<(Self, RealmChangeset?)>`
     */
    public func asObservableChangeset() -> Observable<(Self, RealmChangeset?)> {
        return Observable.create {observer in
            let token = self.addNotificationBlock {changeset in
                
                switch changeset {
                case .Initial(let value):
                    observer.onNext((value, nil))
                case .Update(let value, let deletes, let inserts, let updates):
                    observer.onNext((value, RealmChangeset(deleted: deletes, inserted: inserts, updated: updates)))
                case .Error(let error):
                    observer.onError(error)
                    return
                }
            }
            
            return AnonymousDisposable {
                observer.onCompleted()
                token.stop()
            }
        }
    }
    
    /**
     Returns an `Observable<(Array<Self.Generator.Element>, RealmChangeset?)>` that emits each time the collection data changes. The observable emits an initial value upon subscription.
     
     This method emits an `Array` containing all the realm collection objects, this means they all live in the memory. If you're using this method to observe large collections you might hit memory warnings.
     
     When the observable emits for the first time (if the initial notification is not coalesced with an update) the second tuple value will be `nil`.
     
     Each following emit will include a `RealmChangeset` with the indexes inserted, deleted or modified.
     
     - returns: `Observable<(Array<Self.Generator.Element>, RealmChangeset?)>`
     */
    public func asObservableArrayChangeset() -> Observable<(Array<Self.Generator.Element>, RealmChangeset?)> {
        return asObservableChangeset().map { (Array($0), $1) }
    }
}

public extension Realm {
    
    /**
     Returns an `Observable<(Realm, Notification)>` that emits each time the Realm emits a notification.
     
     The Observable you will get emits a tuple made out of:
     
     * the realm that emitted the event
     * the notification type: this can be either `.DidChange` which occurs after a refresh or a write transaction ends, 
     or `.RefreshRequired` which happens when a write transaction occurs from a different thread on the same realm file
     
     For more information look up: [Notification](https://realm.io/docs/swift/latest/api/Enums/Notification.html)
     
     - returns: `Observable<(Realm, Notification)>`, which you can subscribe to.
     */
    public func asObservable() -> Observable<(Realm, Notification)> {
        return Observable.create {observer in
            let token = self.addNotificationBlock {(notification: Notification, realm: Realm) in
                observer.onNext(realm, notification)
            }
            
            return AnonymousDisposable {
                observer.onCompleted()
                token.stop()
            }
        }
    }

}