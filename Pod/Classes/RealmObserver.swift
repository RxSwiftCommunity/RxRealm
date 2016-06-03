//
//  RealmObserver.swift
//  Pods
//
//  Created by sergdort on 6/3/16.
//
//

import Foundation
import RxSwift
import RealmSwift

/**
 `RealmObserver` doesn't retain target realm object and in case owned realm object is released, element isn't bound.
 
 */
class RealmObserver<E>: ObserverType {
    weak var realm: Realm?
    let binding: (Realm, E) -> Void
    
    init(realm: Realm, binding: (Realm, E) -> Void) {
        self.realm = realm
        self.binding = binding
    }
    /**
     Binds next element realm.
     */
    func on(event: Event<E>) {
        switch event {
        case .Next(let element):
            if let realm = realm {
                binding(realm, element)
            }
        case .Error(let error):
            print("Binding error to Realm: \(error)")
        case .Completed:
            break
        }
    }
    /**
     Erases type of observer.
     
     - returns: type erased observer.
     */
    func asObserver() -> AnyObserver<E> {
        return AnyObserver(eventHandler: on)
    }
}
