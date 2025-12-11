// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "IOS_PhotoEditor",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "IOS_PhotoEditor",
            targets: ["IOS_PhotoEditor"]
        )
    ],
    targets: [
        .target(
            name: "IOS_PhotoEditor",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
