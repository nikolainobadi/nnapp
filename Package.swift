// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nnapp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "nnapp",
            targets: ["nnapp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.0"),
        .package(url: "https://github.com/nikolainobadi/NnGitKit.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/nikolainobadi/NnSwiftDataKit.git", branch: "main"),
        .package(url: "https://github.com/nikolainobadi/SwiftPicker.git", branch: "picker-protocol"),
    ],
    targets: [
        .executableTarget(
            name: "nnapp",
            dependencies: [
                "Files",
                "SwiftShell",
                "SwiftPicker",
                "NnSwiftDataKit",
                .product(name: "GitShellKit", package: "NnGitKit"),
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
