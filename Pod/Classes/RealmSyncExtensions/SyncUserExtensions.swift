//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//  Created by Nate Mann.
//

import Foundation
import RealmSwift
import RxSwift


// MARK: SyncUser extensions

public extension SyncUser {
    /**
     Returns an `Observable<SyncUser>` that emits the current logged in user.
     
     - parameter credentials: A `SyncCredential` object
     - parameter server: The `URL` to log in to
     - returns: `Observable<SyncUser>` will emit the current `SynceUser` once logged in
     */
    static func logIn(with credentials: SyncCredentials, server: URL) -> Observable<SyncUser> {
        return Observable.create({ observer in
            self.logIn(with: credentials, server: server) { user, error in
                if let error = error {
                    observer.onError(error)
                }
                if let user = user {
                    observer.onNext(user)
                }
            }
            return Disposables.create()
        })
    }
    
    /**
     Returns a function from a `SyncCredentials` object to a `Observable<SyncUser>` that emits the current logged in user.
     
     - parameter server: The `URL` to log in to
     - returns: a function from a `SyncCredentials` object to a `Observable<SyncUser>`
     */
    static func logIn(to server: URL) -> (SyncCredentials) -> Observable<SyncUser> {
        return { credentials in
            return Observable.create({ observer in
                self.logIn(with: credentials, server: server) { user, error in
                    if let error = error {
                        observer.onError(error)
                    }
                    if let user = user {
                        observer.onNext(user)
                    }
                }
                return Disposables.create()
            })
        }
    }
    
}
