// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RxRealm",
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/AccioSupport/realm-cocoa.git", .branch("master"))
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
