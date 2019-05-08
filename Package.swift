// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RxRealm",
    dependencies: [
        .package(url: "https://github.com/AccioSupport/realm-cocoa.git", .branch("master"))
    ],
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    targets: [
        .target(
            name: "RxRealm",
            path: "Pod/Classes",
            dependencies: [
                "Realm",
                "RealmSwift"
            ]
        )
    ]
)
