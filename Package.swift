// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-byte-parser-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Byte Parser Primitives",
            targets: ["Byte Parser Primitives"]
        ),
        .library(
            name: "Byte Parser Primitives Test Support",
            targets: ["Byte Parser Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-parser-primitives"),
        .package(path: "../swift-byte-primitives"),
        .package(path: "../swift-either-primitives"),
        .package(path: "../swift-input-primitives"),
        .package(path: "../swift-array-primitives"),
        .package(path: "../swift-cursor-primitives"),
        .package(path: "../swift-byte-cursor-primitives"),
        .package(path: "../swift-memory-cursor-primitives"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Byte Parser Primitives",
            dependencies: [
                .product(name: "Parser Primitives Core", package: "swift-parser-primitives"),
                .product(name: "Parser Match Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser EndOfInput Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser Take Primitives", package: "swift-parser-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Input Primitives", package: "swift-input-primitives"),
                .product(name: "Array Primitives Core", package: "swift-array-primitives"),
                .product(name: "Array Dynamic Primitives", package: "swift-array-primitives"),
                .product(name: "Cursor Primitives", package: "swift-cursor-primitives"),
                .product(name: "Byte Cursor Primitives", package: "swift-byte-cursor-primitives"),
                .product(name: "Memory Cursor Primitives", package: "swift-memory-cursor-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),
        .target(
            name: "Byte Parser Primitives Test Support",
            dependencies: [
                "Byte Parser Primitives",
                .product(name: "Byte Primitives Test Support", package: "swift-byte-primitives"),
                .product(name: "Input Primitives", package: "swift-input-primitives"),
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Byte Parser Primitives Tests",
            dependencies: [
                "Byte Parser Primitives",
                "Byte Parser Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
