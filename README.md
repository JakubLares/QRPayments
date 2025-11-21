# QR Payments - Multiplatform

A multiplatform QR code payment generator app for Czech banking system (SPAYD format), built with **Swift for both iOS and Android** using the new Swift SDK for Android.

## 🏗️ Architecture

This project demonstrates the new **Swift SDK for Android** capabilities, allowing shared business logic written in Swift to run on both iOS and Android platforms.

```
QRPayments/
├── QRPaymentsCore/              # Shared Swift Package
│   ├── Sources/
│   │   └── QRPaymentsCore/
│   │       ├── BankAccount.swift       # Pure Swift model
│   │       ├── SPAYDGenerator.swift    # SPAYD format generator
│   │       ├── PaymentData.swift       # Payment data structure
│   │       └── Validator.swift         # Validation logic
│   └── Package.swift
│
├── QRPayments/                  # iOS App (SwiftUI)
│   ├── App/
│   ├── Models/                  # SwiftData wrapper models
│   ├── Views/                   # SwiftUI screens
│   └── Utilities/               # iOS-specific utilities
│
└── QRPaymentsAndroid/          # Android App (Kotlin + Compose)
    └── app/
        └── src/main/java/com/qrpayments/
            ├── data/            # Android models & repository
            ├── bridge/          # Swift-Kotlin bridge (swift-java)
            ├── ui/              # Jetpack Compose screens
            └── util/            # Android utilities
```

### Platform Distribution

| Component | iOS | Android | Shared |
|-----------|-----|---------|--------|
| **Business Logic** | | | ✅ Swift |
| **SPAYD Generation** | | | ✅ Swift |
| **IBAN Conversion** | | | ✅ Swift |
| **Validation** | | | ✅ Swift |
| **UI Framework** | SwiftUI | Jetpack Compose | ❌ |
| **Data Persistence** | SwiftData | DataStore | ❌ |
| **QR Code Rendering** | CoreImage | ZXing | ❌ |

## ✨ Features

- 📱 **Multiplatform**: Single Swift codebase for business logic
- 🏦 **Czech Banking**: SPAYD format QR codes compatible with all Czech banks
- 💳 **Account Management**: Store multiple bank accounts locally
- 🔢 **IBAN Conversion**: Automatic Czech account → IBAN conversion
- ✅ **Validation**: Shared validation logic via Swift
- 🎨 **Native UI**: SwiftUI on iOS, Jetpack Compose on Android

## 🚀 Getting Started

### Prerequisites

#### For iOS Development
- macOS 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ deployment target

#### For Android Development
- **Swift SDK for Android** ([Download](https://www.swift.org/install/))
- Android Studio Hedgehog (2023.1.1) or later
- JDK 17 or later
- Android SDK with API level 26 (Android 8.0) or higher
- Gradle 8.2 or later

### Installing Swift SDK for Android

1. Download the Swift SDK for Android from [swift.org](https://www.swift.org/blog/nightly-swift-sdk-for-android/)
2. Follow the [Getting Started Guide](https://github.com/swiftlang/swift-android-examples)
3. Install the `swift-java` tooling:
   ```bash
   # Clone the swift-java repository
   git clone https://github.com/swiftlang/swift-java
   cd swift-java

   # Build and install
   swift build -c release
   ```

## 📱 Building the iOS App

1. Open the iOS project:
   ```bash
   cd QRPayments
   open QRPayments.xcodeproj
   ```

2. In Xcode, add the shared package:
   - File → Add Package Dependencies
   - Add Local... → Select `QRPaymentsCore` folder
   - Add to QRPayments target

3. Build and run (⌘R)

## 🤖 Building the Android App

### Current Implementation

The Android app currently includes a **Kotlin implementation** of the Swift logic as a temporary bridge. This allows you to build and run the app immediately while you set up swift-java integration.

1. Open the Android project:
   ```bash
   cd QRPaymentsAndroid
   ```

2. Open in Android Studio or build with Gradle:
   ```bash
   ./gradlew build
   ```

3. Run on emulator or device:
   ```bash
   ./gradlew installDebug
   ```

### Swift-Java Integration (Next Steps)

To integrate the actual Swift `QRPaymentsCore` library:

#### 1. Configure Swift Package for Android

Add Android platform support to `QRPaymentsCore/Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QRPaymentsCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .android(.v26)  // Add Android support
    ],
    products: [
        .library(
            name: "QRPaymentsCore",
            type: .dynamic,  // Required for Android
            targets: ["QRPaymentsCore"]),
    ],
    targets: [
        .target(
            name: "QRPaymentsCore",
            dependencies: [],
            swiftSettings: [
                .define("ANDROID", .when(platforms: [.android]))
            ]
        ),
    ]
)
```

#### 2. Build Swift Library for Android

```bash
cd QRPaymentsCore

# Build for Android ARM64
swift build --swift-sdk aarch64-unknown-linux-android \
    -c release \
    --product QRPaymentsCore

# The output will be in:
# .build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so
```

#### 3. Generate Java Bindings with swift-java

```bash
# Generate Java/Kotlin bindings
swift-java \
    -module QRPaymentsCore \
    -output QRPaymentsAndroid/app/src/main/java/com/qrpayments/bridge/generated

# This generates:
# - Java wrapper classes
# - JNI bindings
# - Kotlin-friendly interfaces
```

#### 4. Update Android Gradle Configuration

Update `QRPaymentsAndroid/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        // ...
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("libs")
        }
    }
}

dependencies {
    // Swift library will be loaded via JNI
    // swift-java generated bindings are already in source
}
```

#### 5. Copy Swift Library to Android Project

```bash
mkdir -p QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a
cp QRPaymentsCore/.build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so \
   QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/
```

#### 6. Replace Kotlin Bridge with Generated Swift Bridge

Update `SwiftBridge.kt` to use the generated bindings:

```kotlin
package com.qrpayments.bridge

import com.qrpayments.bridge.generated.SPAYDGenerator
import com.qrpayments.bridge.generated.Validator

object SwiftBridge {
    init {
        System.loadLibrary("QRPaymentsCore")
    }

    fun generateSPAYD(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ): String {
        return SPAYDGenerator.generate(
            prefix, accountNumber, bankCode,
            amount, variableSymbol, message
        )
    }

    fun isValidBankCode(code: String): Boolean {
        return Validator.isValidBankCode(code)
    }

    // ... other methods using generated Swift bindings
}
```

## 🧪 Testing

### Testing Shared Swift Package

```bash
cd QRPaymentsCore
swift test
```

### Testing iOS App

```bash
cd QRPayments
xcodebuild test -scheme QRPayments -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Testing Android App

```bash
cd QRPaymentsAndroid
./gradlew test
./gradlew connectedAndroidTest
```

## 📖 SPAYD Format

The app generates QR codes in **SPAYD (Short Payment Descriptor)** format, the standard for Czech banking:

```
SPD*1.0*ACC:CZ6508000000192000145399*AM:1000.00*CC:CZK*MSG:Payment*X-VS:1234567890
```

### Format Components

- `SPD*1.0` - Protocol version
- `ACC:<IBAN>` - Account IBAN
- `AM:<amount>` - Amount (optional)
- `CC:CZK` - Currency (always CZK for Czech)
- `MSG:<message>` - Message for receiver (optional)
- `X-VS:<symbol>` - Variable symbol (optional)

## 🏦 Supported Banks

All Czech banks supporting SPAYD QR codes:
- Česká spořitelna
- Komerční banka
- ČSOB
- Raiffeisenbank
- mBank
- Air Bank
- Fio banka
- And more...

## 🔐 Data Privacy

- ✅ All data stored locally on device
- ✅ No cloud sync or external servers
- ✅ No analytics or tracking
- ✅ No internet connection required

## 📚 Resources

### Swift for Android
- [Swift Android SDK Announcement](https://www.swift.org/blog/nightly-swift-sdk-for-android/)
- [Swift Android Examples](https://github.com/swiftlang/swift-android-examples)
- [swift-java Project](https://github.com/swiftlang/swift-java)
- [Swift Forums - Android Category](https://forums.swift.org/c/development/android/)

### Banking Standards
- [SPAYD Specification](https://qr-platba.cz/)
- [Czech Banking QR Codes](https://qr-platba.cz/)

## 🤝 Contributing

This is a demonstration project showing Swift multiplatform capabilities. Feel free to:
1. Fork the repository
2. Experiment with swift-java integration
3. Share your findings

## 📝 License

This project is open source and available for educational purposes.

## 🎯 Current Status

### ✅ Completed
- [x] Shared Swift Package with business logic
- [x] iOS app with SwiftUI
- [x] Android app with Jetpack Compose
- [x] Kotlin bridge implementation (temporary)
- [x] Full feature parity between platforms

### 🚧 Next Steps
- [ ] Integrate swift-java tooling
- [ ] Replace Kotlin bridge with generated Swift bindings
- [ ] Add unit tests for shared package
- [ ] Add CI/CD pipeline for both platforms
- [ ] Performance profiling

## 💡 Notes

The **SwiftBridge.kt** file currently contains a Kotlin implementation of the Swift logic. This is intentional to allow immediate testing of the Android app. Follow the "Swift-Java Integration" section to replace it with actual Swift code via JNI bindings.

The architecture is designed to make this transition seamless - all business logic calls go through the bridge interface, so switching from Kotlin to Swift requires no changes to the UI layer.

## 🐛 Known Issues

1. Swift SDK for Android is currently in preview/nightly builds
2. swift-java tooling may require manual setup
3. Android build requires specific NDK version for ARM64

## 📧 Questions?

For questions about:
- **Swift on Android**: [Swift Forums](https://forums.swift.org/c/development/android/)
- **This Project**: Open an issue on GitHub

## 👨‍💻 Author

Created with ❤️ as a demonstration of Swift multiplatform capabilities
