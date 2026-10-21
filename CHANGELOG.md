# Changelog

All notable changes to this project will be documented in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org).

## [6.0.0](https://github.com/RxSwiftCommunity/RxRealm/compare/v5.1.0...v6.0.0) (unreleased)

### Breaking changes

- Requires RealmSwift 20.0.6 or newer (Realm 20.x). RealmSwift 20.0.6 is the first version that builds with Xcode 26.4+ and Xcode 27 ([#222](https://github.com/RxSwiftCommunity/RxRealm/issues/222), [#220](https://github.com/RxSwiftCommunity/RxRealm/pull/220), [#223](https://github.com/RxSwiftCommunity/RxRealm/pull/223)).
- Minimum deployment targets raised to match RealmSwift 20: iOS 15, macOS 12, tvOS 15, watchOS 9.
- Removed the public `Obs` typealias. Use `RxSwift.Observable` instead.
- Carthage is no longer supported. Use Swift Package Manager.

### Added

- `Observable.from(object:emitInitialValue:properties:on:)` and `Observable.propertyChanges(object:on:)` accept a dispatch queue to deliver notifications on ([#219](https://github.com/RxSwiftCommunity/RxRealm/pull/219)).
- SPM exposes both a static `RxRealm` product and a dynamic `RxRealm-Dynamic` product ([#214](https://github.com/RxSwiftCommunity/RxRealm/issues/214)).

### Changed

- The CocoaPods dependency is now `RealmSwift` only (it pulls in `Realm`), with RxSwift/RxCocoa `~> 6.9`.
- New CI: SwiftLint, `swift test` on macOS, `xcodebuild test` on iOS and tvOS, a watchOS build and `pod lib lint`. Releases are created from `vX.Y.Z` tags on `main` (see RELEASING.md).
- Documentation is hosted on the [Swift Package Index](https://swiftpackageindex.com/RxSwiftCommunity/RxRealm/documentation).

## [5.1.0](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.1.0%0Dv5.0.7) (2024-05-07)

### Fixes

- Update SPM and CocoaPods packages for updated `Realm.swift` packaging linking


## [5.0.7](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.7%0Dv5.0.6) (2024-03-08)

### Updates
- Merge pull request #209 from markusfi/main; update RxRealm.podspec: Realm dependency updated to 10.44

## [5.0.6](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.6%0Dv5.0.5) (2023-10-29)

### Bug Fixes

* ci ([66e43ab](https://github.com/RxSwiftCommunity/RxRealm/commits/66e43ab63448892cbef60d11468614795582a3e2))

## [5.0.5](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.5%0Dv5.0.4) (2022-03-09)

### Bug Fixes

* replacing rx attribute of Realm type by standard Reactive extension. ([dabb105](https://github.com/RxSwiftCommunity/RxRealm/commits/dabb105c94a6c0fdccbf99bb618b618be3f0d5c0))
* update Realm and RxSwift to latest version ([#178](https://github.com/RxSwiftCommunity/RxRealm/issues/178)) ([63d00c6](https://github.com/RxSwiftCommunity/RxRealm/commits/63d00c6349b31d4e26fd5b5a5e428400b6b91356))

## [5.0.4](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.4%0Dv5.0.3) (2022-01-16)

### Bug Fixes

* replacing rx attribute of Realm type by standard Reactive extension. ([dabb105](https://github.com/RxSwiftCommunity/RxRealm/commits/dabb105c94a6c0fdccbf99bb618b618be3f0d5c0))

## [5.0.3](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.3%0Dv5.0.2) (2021-09-05)

## [5.0.2](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.2%0Dv5.0.1) (2021-05-10)

### Bug Fixes

* Brew before generate project ([7eef1d1](https://github.com/RxSwiftCommunity/RxRealm/commits/7eef1d1ba130627af7d140682f912c89830cf1eb))
* Bump version script fix ([8f9f99f](https://github.com/RxSwiftCommunity/RxRealm/commits/8f9f99f4680a07cbeedd63cfb7a26e269b907bf9))

## [5.0.1](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.1%0Dv5.0.0) (2021-01-04)

### Bug Fixes

* Bump version script fix ([8f9f99f](https://github.com/RxSwiftCommunity/RxRealm/commits/8f9f99f4680a07cbeedd63cfb7a26e269b907bf9))

### Bug Fixes

* Bump version script fix ([8f9f99f](https://github.com/RxSwiftCommunity/RxRealm/commits/8f9f99f4680a07cbeedd63cfb7a26e269b907bf9))

## [5.0.0](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v5.0.0%0Dv4.0.3) (2021-01-03)

### ⚠ BREAKING CHANGES

* RxSwift 6.0.0 support

### Features

* Supports xcframework as per release ([09c2a93](https://github.com/RxSwiftCommunity/RxRealm/commits/09c2a93da5e0ca43fa323e2c76f356d07320069d))

### Bug Fixes

* Podspec version ([5c750e7](https://github.com/RxSwiftCommunity/RxRealm/commits/5c750e788284f54b981eaf2d7af5c3f1d61600a8))

## [4.0.3](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v4.0.3%0Dv4.0.2) (2020-12-20)

## [4.0.2](https://github.com/RxSwiftCommunity/RxRealm/branches/compare/v4.0.2%0Dv4.0.1) (2020-12-05)

## 4.0.1 (2020-12-05)

Changelog
=========

3.1.0
_____

- Bump minimum iOS version to 9.0 to sync with realm-cocoa

3.0.0
_____

- added support for Realm 5
- added `queue` optional parameter to `changeset`, `array` and `collection` to specify realm notifications queue
