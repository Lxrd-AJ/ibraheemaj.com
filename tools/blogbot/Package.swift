// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "1bbb",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", "1.0.0"..<"2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "1bbb",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ],
    
)
