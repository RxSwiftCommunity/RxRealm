//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

public protocol NotificationEmitter {
    func addNotification(_: (value: Self?, error: NSError?) -> Void) -> NotificationToken
}

private protocol ArrayType {}
extension Array: ArrayType {}

public extension NotificationEmitter where Self: CollectionType {
    
    private func observable<T>() -> Observable<T> {
        return Observable.create {observer in
            let token = self.addNotification {value, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                if let value = value as? T {
                    observer.onNext(value)
                    return
                }
                
                if let value = value, case _ = T.self as? ArrayType {
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

extension List: NotificationEmitter {
    public func addNotification(block: (value: List?, error: NSError?) -> Void) -> NotificationToken {
        return addNotificationBlock {list in
            block(value: list, error: nil)
        }
    }
}

extension AnyRealmCollection: NotificationEmitter {
    public func addNotification(block: (value: AnyRealmCollection?, error: NSError?) -> Void) -> NotificationToken {
        return addNotificationBlock(block)
    }
}

extension Results: NotificationEmitter {
    public func addNotification(block: (value: Results?, error: NSError?) -> Void) -> NotificationToken {
        return addNotificationBlock(block)
    }
}