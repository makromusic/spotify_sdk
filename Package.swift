// swift-tools-version:5.9
//
// Exists only so the parts of the iOS plugin that carry real decision logic can be unit tested with
// `swift test`, without an Xcode project, a Flutter host app, or the Spotify framework. It is not
// how the plugin ships -- CocoaPods builds `ios/Classes` via `ios/spotify_sdk.podspec` -- so only
// files that are free of Flutter and SpotifyiOS imports can be listed here.
import PackageDescription

let package = Package(
    name: "SpotifyRedirectRouting",
    platforms: [.macOS(.v10_15)],
    targets: [
        .target(
            name: "SpotifyRedirectRouting",
            path: "ios/Classes",
            sources: ["SpotifyRedirectRouting.swift"]
        ),
        .testTarget(
            name: "SpotifyRedirectRoutingTests",
            dependencies: ["SpotifyRedirectRouting"],
            path: "ios/Tests"
        ),
    ]
)
