// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "RxRealm",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v9)
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
        .package(url: "https://github.com/realm/realm-swift.git", from: "20.0.6"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.9.0")
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
            dependencies: [
                "RxRealm",
                .product(name: "RxBlocking", package: "RxSwift")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
