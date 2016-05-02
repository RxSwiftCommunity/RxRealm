//
//  TestModels.swift
//  RxRealm
//
//  Created by Marin Todorov on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import RealmSwift

//MARK: Message
class Message: Object, Equatable {
    
    dynamic var text = ""
    
    let recipients = List<User>()
    let mentions = LinkingObjects(fromType: User.self, property: "lastMessage")
    
    convenience init(_ text: String) {
        self.init()
        self.text = text
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text
}

//MARK: User
class User: Object, Equatable {
    dynamic var name = ""
    dynamic var lastMessage: Message?
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.name == rhs.name
}