//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

public protocol NotificationEmitter {
    func addNotificationBlock(block: (RealmCollectionChange<Self>) -> ()) -> NotificationToken
}

extension List: NotificationEmitter {}
extension AnyRealmCollection: NotificationEmitter {}
extension Results: NotificationEmitter {}
extension LinkingObjects: NotificationEmitter {}

public struct RealmChangeset {
    public let deleted: [Int]
    public let inserted: [Int]
    public let updated: [Int]
}

public extension NotificationEmitter where Self: RealmCollectionType {
    
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
                token.stop()
            }
        }
    }
    
    public func asObservableArray() -> Observable<Array<Self.Generator.Element>> {
        return asObservable().map { Array($0) }
    }

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
                token.stop()
            }
        }
    }
    
    public func asObservableArrayChangeset() -> Observable<(Array<Self.Generator.Element>, RealmChangeset?)> {
        return asObservableChangeset().map { (Array($0), $1) }
    }
}