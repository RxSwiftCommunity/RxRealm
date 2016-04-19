//
//  ViewController.swift
//  RxRealm
//
//  Created by Marin Todorov on 04/19/2016.
//  Copyright (c) 2016 Marin Todorov. All rights reserved.
//

import UIKit

import RxSwift
import RealmSwift
import RxRealm

func delay(delay: NSTimeInterval, block: dispatch_block_t) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), block)
}

class Dog: Object {}

class Person: Object {
    let dogs = List<Dog>()
}

class ViewController: UIViewController {
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        let person = Person(value: ["dogs": [Dog()]])
        try! realm.write {
            realm.add(person)
        }
        
        person.dogs.asObservableArray()
            .subscribeNext{list in
                print("count as list: \(list.count)")
        }.addDisposableTo(bag)
        
        
        realm.objects(Person).asObservable()
            .subscribeNext {result in
                print("count as results: \(result.count)")
        }.addDisposableTo(bag)

        realm.objects(Person).asObservableArray()
            .subscribeNext {array in
                print("count as array: \(array.count)")
        }.addDisposableTo(bag)
        
        delay(1, block: {
            let realm = try! Realm()
            try! realm.write {
                realm.add(Person())
                realm.objects(Person).first!.dogs.appendContentsOf([Dog(), Dog()])
            }
        })
    }
    
}