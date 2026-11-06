// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppKitData",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "AppKitData", targets: ["AppKitData"]),
    ],
    dependencies: [
        .package(path: "../AppKitCore"),
    ],
    targets: [
        .target(name: "AppKitData", dependencies: ["AppKitCore"]),
        .testTarget(name: "AppKitDataTests", dependencies: ["AppKitData", "AppKitCore"]),
    ]
)
