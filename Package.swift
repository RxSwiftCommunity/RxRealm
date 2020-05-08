// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RxRealm",
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.1.1")),
        .package(url: "https://github.com/realm/realm-cocoa.git", .upToNextMajor(from: "4.4.1"))
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
