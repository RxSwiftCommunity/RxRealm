// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RxRealm",
    products: [
        .library(name: "RxRealm", targets: ["RxRealm"])
    ],
    targets: [
        .target(
            name: "RxRealm",
            path: "Pod/Classes"
        )
    ]
)
