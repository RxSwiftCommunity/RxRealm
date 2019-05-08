// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RxRealm",
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/realm/realm-cocoa.git", .revision("7c627b44f4d73aaa5e385aeb0fae7775d3ece85b"))
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
