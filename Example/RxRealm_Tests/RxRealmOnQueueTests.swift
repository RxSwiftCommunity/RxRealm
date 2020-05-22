//
//  RxRealmOnQueueTests.swift
//  RxRealm_Tests
//
//  Created by Anton Nazarov on 18.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import RxSwift

final class RxRealmOnQueueTests: XCTestCase {
    func testCollectionOnQueue() {
        let realm = realmInMemory()
        DispatchQueue.main.async {
            try! realm.write {
                realm.add(UniqueObject(1))
            }
            try! realm.write {
                realm.add(UniqueObject(2))
            }
        }
        let dispatchedOnMainTread = try! Observable.changeset(from: realm.objects(UniqueObject.self), on: DispatchQueue(label: #function))
            .map { _ in Thread.isMainThread }
            .take(2)
            .toBlocking()
            .toArray()
        XCTAssertEqual(dispatchedOnMainTread, [true, false])
    }

    func testArrayOnQueue() {
        let realm = realmInMemory()
        DispatchQueue.main.async {
            try! realm.write {
                realm.add(UniqueObject(1))
            }
            try! realm.write {
                  realm.add(UniqueObject(2))
              }
        }
        let dispatchedOnMainTread = try! Observable.changeset(from: realm.objects(UniqueObject.self), on: DispatchQueue(label: #function))
            .map { _ in Thread.isMainThread }
            .take(2)
            .toBlocking()
            .toArray()
        XCTAssertEqual(dispatchedOnMainTread, [true, false])
    }

    func testChangesetOnQueue() {
        let realm = realmInMemory()
        DispatchQueue.main.async {
            try! realm.write {
                realm.add(UniqueObject(1))
            }
            try! realm.write {
                  realm.add(UniqueObject(2))
              }
        }
        let dispatchedOnMainTread = try! Observable.changeset(from: realm.objects(UniqueObject.self), on: DispatchQueue(label: #function))
            .map { _ in Thread.isMainThread }
            .take(2)
            .toBlocking()
            .toArray()
        XCTAssertEqual(dispatchedOnMainTread, [true, false])
    }
}
