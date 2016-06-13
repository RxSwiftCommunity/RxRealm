# RxRealm

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![License](https://img.shields.io/cocoapods/l/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)
[![Platform](https://img.shields.io/cocoapods/p/RxRealm.svg?style=flat)](http://cocoapods.org/pods/RxRealm)

## Usage

This library is a thin wrapper around __RealmSwift__.

### Observing collections

RxRealm adds to `Results`, `List`, `LinkingObjects` and `AnyRealmCollection` these methods:

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

### Write transactions

#### rx_add()

__write to existing realm reference)__ You can add newly created objects to a realm that you already have initialized:

```swift
let realm = try! Realm()
[Message("hello"), Message("world")].toObservable()
  .subscribe(realm.rx_add())
```

Be careful, this will retain your realm until the `Observable` completes or errors out.

__write to the default realm)__ You can leave it to RxRealm to grab the default Realm on any thread your subscribe and write objects to it:

```swift
[Message("hello"), Message("world")].toObservable()
  .observeOn(  ..you can switch threads if you want )
  .subscribe(Realm.rx_add())
```

__write to a specific realm)__ If you want to switch threads and don't use the default realm, provide a `Realm.Configuration`:

```swift
var conf = Realm.Configuration()
... custom configuration settings ...

[Message("hello"), Message("world")].toObservable()
  .observeOn(  ..you can switch threads if you want )
  .subscribe(Realm.rx_add(conf))
```

If you want to create yourself the Realm on a different thread than the subscription you can do that too (allows you to error handle):

```swift
[Message("hello"), Message("world")].toObservable()
  .observeOn(  ..you can switch threads if you want )
  .subscribeNext {messages in
    let realm = try! Realm()
    try! realm.write {
      realm.add(messages)
    }
  }
```

#### rx_delete()

__delete from existing realm reference)__ Delete objects from existing realm reference:

```swift
let realm = try! Realm()
realm.objects(Messages).asObservable()
  .subscribe(realm.rx_delete())
```

Be careful, this will retain your realm until the `Observable` completes or errors out.

__delete automatically from objects' realm)__ You can leave it to RxRealm to grab the Realm from the first object and use it:

```swift
someCollectionOfPersistedObjects.toObservable()
  .subscribe(Realm.rx_delete())
```


## Example app

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

You can grab the files in `Pod/Classes` from this repo and include them in your project.

## TODO

* Test add platforms and add compatibility for the pod

## License

This library belongs to _RxSwiftCommunity_.

RxRealm is available under the MIT license. See the LICENSE file for more info.
