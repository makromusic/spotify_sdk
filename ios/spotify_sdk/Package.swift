// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spotify_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "spotify-sdk", targets: ["spotify_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Same version prepare-iOS-SDK.sh pins for CocoaPods. spotify/ios-sdk ships its own
        // Package.swift (a binaryTarget over SpotifyiOS.xcframework), so SwiftPM needs no prepare step.
        .package(url: "https://github.com/spotify/ios-sdk.git", exact: "5.0.1")
    ],
    targets: [
        .target(
            name: "spotify_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "SpotifyiOS", package: "ios-sdk")
            ]
        )
    ]
)
