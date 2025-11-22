// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRPaymentsCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        // Android support via Linux platform
        .linux
    ],
    products: [
        // Library that can be static or dynamic based on context
        .library(
            name: "QRPaymentsCore",
            type: .dynamic, // Required for JNI on Android
            targets: ["QRPaymentsCore"]),
    ],
    targets: [
        .target(
            name: "QRPaymentsCore",
            dependencies: [],
            swiftSettings: [
                // Add Android-specific compilation flag
                .define("ANDROID", .when(platforms: [.linux])),
                // Use Swift 6 language mode for better compatibility
                .enableUpcomingFeature("StrictConcurrency")
            ]),
        .testTarget(
            name: "QRPaymentsCoreTests",
            dependencies: ["QRPaymentsCore"]),
    ]
)
