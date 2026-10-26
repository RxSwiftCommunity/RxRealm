//
//  RxRealmKeyPathTests.swift
//  RxRealm
//

import XCTest

import RealmSwift
import RxRealm
import RxSwift

class RxRealmKeyPathTests: XCTestCase {
  private var disposeBag = DisposeBag()

  override func tearDown() {
    disposeBag = DisposeBag()
    super.tearDown()
  }

  private func makeDogs(_ name: String) -> (Realm, Results<Dog>) {
    let realm = realmInMemory(name)
    try! realm.write {
      realm.add(Dog("rex"))
    }
    return (realm, realm.objects(Dog.self))
  }

  func testChangesetSkipsChangesOutsideKeyPaths() {
    let (realm, dogs) = makeDogs(#function)
    var changesets: [RealmChangeset?] = []
    Observable.changeset(from: dogs, keyPaths: ["name"])
      .subscribe(onNext: { changesets.append($0.1) })
      .disposed(by: disposeBag)

    XCTAssertTrue(writeAndWaitForDelivery(realm, Dog.self) {
      try! realm.write { dogs.first!.age = 3 }
    })
    XCTAssertEqual(changesets.count, 1, "only the synchronous start")

    XCTAssertTrue(writeAndWaitForDelivery(realm, Dog.self) {
      try! realm.write { dogs.first!.name = "max" }
    })
    XCTAssertEqual(changesets.count, 2)
    XCTAssertEqual(changesets.last??.updated, [0])
  }

  func testArraySkipsChangesOutsideKeyPaths() {
    let (realm, dogs) = makeDogs(#function)
    var names: [[String]] = []
    Observable.array(from: dogs, keyPaths: ["name"])
      .subscribe(onNext: { names.append($0.map { $0.name }) })
      .disposed(by: disposeBag)

    XCTAssertTrue(writeAndWaitForDelivery(realm, Dog.self) {
      try! realm.write { dogs.first!.age = 3 }
    })
    XCTAssertTrue(writeAndWaitForDelivery(realm, Dog.self) {
      try! realm.write { dogs.first!.name = "max" }
    })
    XCTAssertEqual(names, [["rex"], ["max"]])
  }

  func testArrayWithChangesetSkipsChangesOutsideKeyPaths() {
    let (realm, dogs) = makeDogs(#function)
    var changesets: [RealmChangeset?] = []
    Observable.arrayWithChangeset(from: dogs, keyPaths: ["name"])
      .subscribe(onNext: { changesets.append($0.1) })
      .disposed(by: disposeBag)

    XCTAssertTrue(writeAndWaitForDelivery(realm, Dog.self) {
      try! realm.write { dogs.first!.age = 3 }
    })
    XCTAssertTrue(writeAndWaitForDelivery(realm, Dog.self) {
      try! realm.write { dogs.first!.name = "max" }
    })
    XCTAssertEqual(changesets.count, 2)
    XCTAssertEqual(changesets.last??.updated, [0])
  }

  func testArrayWithChangesetHonorsSynchronousStart() {
    let (_, dogs) = makeDogs(#function)
    var emissions = 0
    Observable.arrayWithChangeset(from: dogs, synchronousStart: false)
      .subscribe(onNext: { _ in emissions += 1 })
      .disposed(by: disposeBag)

    XCTAssertEqual(emissions, 0, "nothing is emitted synchronously")
    XCTAssertTrue(runRunLoop(until: { emissions == 1 }))
  }
}
