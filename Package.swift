// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nnapp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "nnapp",
            targets: ["nnapp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/SwiftPicker.git", from: "0.8.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "nnapp",
            dependencies: [
                "SwiftPicker",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Resources/Info.plist"
                ])
            ]
        ),
        .testTarget(
            name: "nnappTests",
            dependencies: ["nnapp"]),
    ]
)
