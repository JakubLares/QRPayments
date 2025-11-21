# Swift for Android - Integration Guide

This guide explains how to integrate the Swift QRPaymentsCore library with the Android app using swift-java.

## Current State

The Android app is **fully functional** with a Kotlin implementation of the Swift business logic. This allows you to:
- ✅ Build and run the app immediately
- ✅ Test all features
- ✅ See the multiplatform architecture in action

## Why Kotlin Bridge First?

The Swift SDK for Android is still in preview (nightly builds), and swift-java tooling requires manual setup. By providing a working Kotlin implementation first, you can:
1. Verify the app architecture
2. Test the UI and features
3. Understand the integration points
4. Migrate to Swift gradually

## Architecture

```
┌─────────────────────────────────────────┐
│          Android UI Layer               │
│      (Jetpack Compose - Kotlin)         │
└─────────────┬───────────────────────────┘
              │
              ├── calls bridge interface
              │
┌─────────────▼───────────────────────────┐
│         SwiftBridge.kt                  │
│    (Interface abstraction layer)        │
└─────────────┬───────────────────────────┘
              │
              ├── Currently: Kotlin implementation
              │   Future: Swift via JNI
              │
┌─────────────▼───────────────────────────┐
│     Business Logic Implementation       │
│                                          │
│  [NOW]  Kotlin (temporary)              │
│  [NEXT] Swift via swift-java + JNI      │
│                                          │
│  - SPAYD generation                     │
│  - IBAN conversion                      │
│  - Validation                           │
└──────────────────────────────────────────┘
```

## Migration Path to Swift

### Phase 1: Current State ✅

- [x] Kotlin implementation in SwiftBridge.kt
- [x] Full feature parity with iOS
- [x] App builds and runs

### Phase 2: Swift SDK Setup (Your next steps)

1. **Install Swift SDK for Android**
   ```bash
   # Download from swift.org
   # Follow official installation guide
   ```

2. **Install swift-java tooling**
   ```bash
   git clone https://github.com/swiftlang/swift-java
   cd swift-java
   swift build -c release
   # Add to PATH
   ```

3. **Verify installation**
   ```bash
   swift --version
   swift-java --help
   ```

### Phase 3: Build Swift Library for Android

1. **Update Package.swift**

   Currently:
   ```swift
   platforms: [
       .iOS(.v17),
       .macOS(.v14)
   ]
   ```

   Change to:
   ```swift
   platforms: [
       .iOS(.v17),
       .macOS(.v14),
       .android(.v26)  // Add this
   ]
   ```

2. **Build for Android ARM64**
   ```bash
   cd QRPaymentsCore

   swift build \
       --swift-sdk aarch64-unknown-linux-android \
       -c release \
       --product QRPaymentsCore
   ```

3. **Verify output**
   ```bash
   ls -lh .build/aarch64-unknown-linux-android/release/
   # Should see: libQRPaymentsCore.so
   ```

### Phase 4: Generate JNI Bindings

1. **Run swift-java generator**
   ```bash
   swift-java \
       -module QRPaymentsCore \
       -output QRPaymentsAndroid/app/src/main/java/com/qrpayments/bridge/generated
   ```

2. **Generated files**
   ```
   QRPaymentsAndroid/app/src/main/java/com/qrpayments/bridge/generated/
   ├── SPAYDGenerator.java
   ├── Validator.java
   ├── BankAccount.java
   ├── PaymentData.java
   └── (JNI wrapper code)
   ```

### Phase 5: Integrate Swift Library

1. **Copy .so file to Android project**
   ```bash
   mkdir -p QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a

   cp QRPaymentsCore/.build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so \
      QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/
   ```

2. **Update build.gradle.kts**
   ```kotlin
   android {
       defaultConfig {
           ndk {
               abiFilters += listOf("arm64-v8a")
           }
       }
   }
   ```

3. **Update SwiftBridge.kt**

   Replace Kotlin implementation with:
   ```kotlin
   package com.qrpayments.bridge

   import com.qrpayments.bridge.generated.*

   object SwiftBridge {
       init {
           System.loadLibrary("QRPaymentsCore")
       }

       fun generateSPAYD(...): String {
           return SPAYDGenerator.generate(...)  // Calls Swift via JNI
       }

       fun isValidBankCode(code: String): Boolean {
           return Validator.isValidBankCode(code)  // Calls Swift via JNI
       }

       // ... rest of the interface
   }
   ```

4. **Build and test**
   ```bash
   cd QRPaymentsAndroid
   ./gradlew clean build
   ./gradlew installDebug
   ```

## Testing Swift Integration

Once integrated, test that:

1. **Library loads**
   ```kotlin
   // Should not crash
   SwiftBridge.isValidBankCode("0800")
   ```

2. **SPAYD generation works**
   ```kotlin
   val spayd = SwiftBridge.generateSPAYD(
       prefix = "19",
       accountNumber = "2121134949",
       bankCode = "6100",
       amount = "1000",
       variableSymbol = null,
       message = null
   )
   println(spayd)
   // Should output valid SPAYD string
   ```

3. **IBAN conversion is correct**
   ```kotlin
   // Czech account: 19-2121134949/6100
   // Should convert to: CZ...6100000019002121134949
   ```

## Troubleshooting

### Build Errors

**Error:** `swift-sdk not found`
```bash
# Install Swift SDK for Android
# Verify: swift --version
```

**Error:** `libQRPaymentsCore.so not found`
```bash
# Check file location
ls QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/

# Verify library info
file libQRPaymentsCore.so
```

### Runtime Errors

**Error:** `UnsatisfiedLinkError: dlopen failed`
```kotlin
// Check library loading
android {
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}
```

**Error:** Method not found in JNI
```bash
# Regenerate bindings
swift-java -module QRPaymentsCore -output ...
```

## Verification Checklist

Before considering migration complete:

- [ ] Swift SDK for Android installed
- [ ] swift-java tooling available
- [ ] QRPaymentsCore builds for Android target
- [ ] libQRPaymentsCore.so generated
- [ ] Java bindings generated by swift-java
- [ ] .so file copied to jniLibs/arm64-v8a/
- [ ] SwiftBridge.kt updated to use generated bindings
- [ ] App builds without errors
- [ ] App runs on Android device/emulator
- [ ] All features work correctly
- [ ] SPAYD strings match iOS implementation
- [ ] QR codes scan successfully in banking apps

## Comparison: Kotlin vs Swift Implementation

| Aspect | Kotlin Bridge | Swift via JNI |
|--------|---------------|---------------|
| **Setup** | ✅ Immediate | ⏳ Requires SDK setup |
| **Performance** | 🔵 Native Kotlin | 🟢 Native Swift |
| **Code Reuse** | ❌ Duplicated | ✅ Shared with iOS |
| **Maintenance** | ⚠️ Two codebases | ✅ Single codebase |
| **Type Safety** | ✅ Kotlin types | ✅ Swift types via bindings |
| **Debugging** | ✅ Standard Android | 🔵 Requires NDK setup |

## Next Steps

1. **Test current Kotlin implementation**
   - Build and run the Android app
   - Verify all features work
   - Compare with iOS app

2. **Install Swift SDK for Android**
   - Follow official guide
   - Verify installation

3. **Build Swift library**
   - Follow Phase 3 above
   - Verify .so file generation

4. **Generate bindings**
   - Follow Phase 4 above
   - Review generated Java code

5. **Integrate and test**
   - Follow Phase 5 above
   - Run comprehensive tests

## Resources

- **Swift for Android**: https://www.swift.org/blog/nightly-swift-sdk-for-android/
- **swift-java**: https://github.com/swiftlang/swift-java
- **Examples**: https://github.com/swiftlang/swift-android-examples
- **Forums**: https://forums.swift.org/c/development/android/

## Questions?

If you encounter issues:
1. Check the Swift Forums Android category
2. Review swift-android-examples repository
3. Open an issue with detailed error logs

Good luck with your Swift multiplatform journey! 🚀
