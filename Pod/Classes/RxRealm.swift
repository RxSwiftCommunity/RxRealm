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

private protocol ArrayType {}
extension Array: ArrayType {}

public extension NotificationEmitter where Self: RealmCollectionType {
    
    private func observable<T>() -> Observable<T> {
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

                if let value = value as? T {
                    observer.onNext(value)
                    return
                }
                
                if case _ = T.self as? ArrayType {
                    observer.onNext(Array(value) as! T)
                    return
                }
                
                fatalError("Unexpected Observable type")
            }
            
            return AnonymousDisposable {
                token.stop()
            }
        }
    }
    
    public func asObservableArray() -> Observable<Array<Self.Generator.Element>> {
        return observable()
    }
    
    public func asObservable() -> Observable<Self> {
        return observable()
    }
}