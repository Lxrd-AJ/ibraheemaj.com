// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "1bbb",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", "0.2.1"..<"0.3.0")
    ],
    targets: [
        .executableTarget(
            name: "1bbb",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Subprocess", package: "swift-subprocess")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ],
        ),
    ],
    
)