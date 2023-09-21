// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "Brick_SwiftUI")

package.platforms = [
    .iOS(.v14),
    .tvOS(.v14),
//    .watchOS(.v7),
    .macOS(.v11),
//    .xrOS(.v1)
]

package.products = [
    .library(name: "BrickKit", targets: ["BrickKit"]),
    .library(name: "CameraKit", targets: ["CameraKit"]),
]

package.targets = [
    .target(name: "BrickKit", path: "Sources/Brick"),
    .target(name: "CameraKit", dependencies: ["BrickKit"], path: "Sources/Camera"),
]

package.swiftLanguageVersions = [.v5]
