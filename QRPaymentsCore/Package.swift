// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRPaymentsCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
        // Note: Android support is enabled automatically
        // Android runs on Linux kernel, so Swift treats it as Linux target
        // We build on macOS, cross-compile for Android (Linux-based)
    ],
    products: [
        // Library that can be static or dynamic based on context
        .library(
            name: "QRPaymentsCore",
            type: .dynamic, // Required for JNI on Android
            targets: ["QRPaymentsCore"]),
    ],
    dependencies: [
        // Swift-Java interoperability (official Swift.org project)
        // Enables @JavaExport macro for automatic JNI binding generation
        .package(url: "https://github.com/swiftlang/swift-java.git", branch: "main")
    ],
    targets: [
        .target(
            name: "QRPaymentsCore",
            dependencies: [
                .product(name: "SwiftJava", package: "swift-java"),
                .product(name: "JavaTypes", package: "swift-java"),
            ],
            swiftSettings: [
                // Android-specific compilation flag
                // Android uses Linux kernel, so we check for .linux platform
                // This activates when cross-compiling from macOS to Android
                .define("ANDROID", .when(platforms: [.linux]))
                // Note: StrictConcurrency is already enabled by default in Swift 6
            ]),
        .testTarget(
            name: "QRPaymentsCoreTests",
            dependencies: ["QRPaymentsCore"]),
    ]
)
