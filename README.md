[WIP] We'll hold on an official release as we convert the lib to the new fine grained notifications from Realm.

# RxRealm

[![Version](https://img.shields.io/cocoapods/v/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![License](https://img.shields.io/cocoapods/l/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![Platform](https://img.shields.io/cocoapods/p/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)

## Usage

This library is a very thin wrapper around the reactive classes __RealmSwift__ provides: `Results`, `List` and `AnyRealmCollection`. 

The extension adds two  methods to all of the above classes:

### asObservable()
`asObservable()` - emits every time the collection changes:

```swift
let realm = try! Realm()
realm.objects(Lap).asObservable()
  .map {laps in "\(laps.count) laps"}
  .subscribeNext { text  in
    print(text)
  }
```

### asObservableArray()
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


## Example app

To run the example project, clone the repo, and run `pod install` from the Example directory first. The app uses RxSwift, RxCocoa using RealmSwift, RxRealm to observe Results from Realm.

## Requirements

This library depends on both __RxSwift__ and __RealmSwift__.

## Installation

### CocoaPods
RxRealm is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "RxRealm"
```

### Carthage

Coming soon (feel free to send a PR)

### Source

You can grab the __RxRealm.swift__ file from this repo and include it in your project.

## Author

This library belongs to _RxSwiftCommunity_ and is based on the work of [@fpillet](https://github.com/fpillet)

## TODO

* Carthage

## License

RxRealm is available under the MIT license. See the LICENSE file for more info.
