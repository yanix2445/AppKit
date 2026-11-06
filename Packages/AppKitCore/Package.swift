// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppKitCore",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "AppKitCore", targets: ["AppKitCore"]),
    ],
    targets: [
        .target(name: "AppKitCore"),
        .testTarget(name: "AppKitCoreTests", dependencies: ["AppKitCore"]),
    ]
)
