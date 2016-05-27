# RxRealm

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![License](https://img.shields.io/cocoapods/l/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![Platform](https://img.shields.io/cocoapods/p/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)

## Usage

This library is a very thin wrapper around the reactive collection types that  __RealmSwift__ provides.

The extension adds to `Results`, `List`, `LinkingObjects` and `AnyRealmCollection` these methods:

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

Further you're welcome to peak into the __RxRealmTests__ folder of the example app, which features the library's unit tests.

## Installation

This library depends on both __RxSwift__ and __RealmSwift__ 1.0+.

#### CocoaPods
RxRealm is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "RxRealm"
```

#### Carthage

RxRealm is available through [Carthage](https://github.com/Carthage/Carthage). You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate RxRealm into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "RxSwiftCommunity/RxRealm" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `RxRealm.framework` into your Xcode project.

#### As Source

You can grab the __RxRealm.swift__ file from this repo and include it in your project.

## TODO

* Carthage
* Add `asObservable()` to the Realm class
* Test add platforms and add compatibility for the pod

## License

This library belongs to _RxSwiftCommunity_.

RxRealm is available under the MIT license. See the LICENSE file for more info.
