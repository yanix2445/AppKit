// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppKitSystem",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "AppKitSystem", targets: ["AppKitSystem"]),
        .library(name: "AppKitSystemTesting", targets: ["AppKitSystemTesting"]),
    ],
    dependencies: [
        .package(path: "../AppKitCore"),
    ],
    targets: [
        .target(name: "AppKitSystem", dependencies: ["AppKitCore"]),
        .target(name: "AppKitSystemTesting", dependencies: ["AppKitSystem", "AppKitCore"]),
        .testTarget(
            name: "AppKitSystemTests",
            dependencies: ["AppKitSystem", "AppKitSystemTesting", "AppKitCore"]
        ),
    ]
)
