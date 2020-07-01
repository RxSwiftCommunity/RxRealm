// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RxRealm",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v11),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/realm/realm-cocoa.git", .upToNextMajor(from: "5.2.0"))
    ],
    targets: [
        .target(
            name: "RxRealm",
            dependencies: [
                    "RxSwift",
                    "RxCocoa",
                    "Realm",
                    "RealmSwift"
                ],
            path: "Pod/Classes"
        )
    ]
)
