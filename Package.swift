// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoEditorKit",
    platforms: [
        .iOS(.v14) // iOS 14+ for SwiftUI features (onChange, etc.)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PhotoEditorKit",
            targets: ["PhotoEditorKit"]),
    ],
    dependencies: [
        // No external dependencies - uses native iOS frameworks only
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "PhotoEditorKit",
            dependencies: [],
            path: "Sources/PhotoEditorKit"
        ),
        .testTarget(
            name: "PhotoEditorKitTests",
            dependencies: ["PhotoEditorKit"],
            path: "Tests/PhotoEditorKitTests"
        ),
    ]
)

