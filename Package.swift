// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "RxRealm",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v4)
    ],
    products: [
        .library(
            name: "RxRealm",
            type: .static,
            targets: ["RxRealm"]
        ),
        .library(
            name: "RxRealm-Dynamic",
            type: .dynamic,
            targets: ["RxRealm"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.50.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.1")
    ],
    targets: [
        .target(
            name: "RxRealm",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Sources"),
        .testTarget(
            name: "RxRealmTests",
            dependencies: ["RxRealm"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
