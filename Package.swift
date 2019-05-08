// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RxRealm",
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    dependencies: [
        .package(url: "https://github.com/AccioSupport/realm-cocoa.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "RxRealm",
            dependencies: [
                    "Realm",
                    "RealmSwift"
                ],
            path: "Pod/Classes"
        )
    ]
)
