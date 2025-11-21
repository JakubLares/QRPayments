// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRPaymentsCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Static library for iOS/macOS
        .library(
            name: "QRPaymentsCore",
            targets: ["QRPaymentsCore"]),
        // Dynamic library for Android (JNI)
        .library(
            name: "QRPaymentsCore",
            type: .dynamic,
            targets: ["QRPaymentsCore"]),
    ],
    targets: [
        .target(
            name: "QRPaymentsCore",
            dependencies: [],
            swiftSettings: [
                // Add Android-specific compilation flag
                .define("ANDROID", .when(platforms: [.linux]))
            ]),
        .testTarget(
            name: "QRPaymentsCoreTests",
            dependencies: ["QRPaymentsCore"]),
    ]
)
