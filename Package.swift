// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClockedOut",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ClockedOut",
            targets: ["ClockedOut"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "ClockedOut",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ]),
        .testTarget(
            name: "ClockedOutTests",
            dependencies: ["ClockedOut"]),
    ]
)

