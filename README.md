# RxRealm

[![Version](https://img.shields.io/cocoapods/v/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![License](https://img.shields.io/cocoapods/l/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![Platform](https://img.shields.io/cocoapods/p/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)

## Usage

This library is a very thin wrapper around the reactive collection types __RealmSwift__ provides: `Results`, `List` and `AnyRealmCollection`. 

The extension adds these methods to all of the above:

#### asObservable()
`asObservable()` - emits every time the collection changes:

```swift
let realm = try! Realm()
realm.objects(Lap).asObservable()
  .map {laps in "\(laps.count) laps"}
  .subscribeNext { text  in
    print(text)
  }
```

#### asObservableArray()
`asObservableArray()` - fetches the a snapshot of a Realm collection and converts it to an array value (for example if you want to use array methods on the collection):

```swift
let realm = try! Realm()
realm.objects(Lap).asObservableArray()
  .map {array in
    return array.prefix(3) //slice of first 3 items
  }
  .subscribeNext { text  in
    print(text)
  }
```

#### asObservableChangeset()
`asObservableChangeset()` - emits every time the collection changes and provides the exact indexes that has been deleted, inserted or updated:

```swift
let realm = try! Realm()
realm.objects(Lap).asObservableChangeset()
  .subscribeNext {result, changes in
    if let changes = changes {
	  //it's an update
	  print(result)
	  print("deleted: \(changes.deleted) inserted: \(changes.inserted) updated: \(changes.updated)")
	} else {
	  //it's the initial data
	  print(result)
	}
  }
```

#### asObservableArrayChangeset()

`asObservableArrayChangeset()` combines the result of `asObservableArray()` and `asObservableChangeset()` returning an `Observable<Array<T>, RealmChangeset?>`.

#### Example app

To run the example project, clone the repo, and run `pod install` from the Example directory first. The app uses RxSwift, RxCocoa using RealmSwift, RxRealm to observe Results from Realm.

## Installation

This library depends on both __RxSwift__ and __RealmSwift__ 0.99+.

#### CocoaPods
RxRealm is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "RxRealm"
```

#### Carthage

Feel free to send a PR

#### As Source

You can grab the __RxRealm.swift__ file from this repo and include it in your project.

## Author

This library belongs to _RxSwiftCommunity_ and is based on the work of [@fpillet](https://github.com/fpillet)

## TODO

* Carthage
* Add `asObservable()` to the Realm class
* Test add platforms and add compatibility for the pod
* Document the source code

## License

RxRealm is available under the MIT license. See the LICENSE file for more info.
