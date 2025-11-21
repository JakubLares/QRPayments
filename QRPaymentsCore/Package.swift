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
        .library(
            name: "QRPaymentsCore",
            targets: ["QRPaymentsCore"]),
    ],
    targets: [
        .target(
            name: "QRPaymentsCore",
            dependencies: []),
        .testTarget(
            name: "QRPaymentsCoreTests",
            dependencies: ["QRPaymentsCore"]),
    ]
)
