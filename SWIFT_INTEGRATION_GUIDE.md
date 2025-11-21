# Swift-Android Integration Guide

Complete guide to integrate real Swift code with your Android app using swift-java.

## 🎯 What You're About to Do

Replace the Kotlin bridge (`SwiftBridge.kt`) with actual Swift code running via JNI. Your Android app will call the same Swift code that runs on iOS!

## ⚡ Quick Start

If you have everything installed, just run:

```bash
./integrate-swift-android.sh
```

Otherwise, follow the detailed steps below.

---

## 📋 Prerequisites

### 1. Install Swift SDK for Android

**Download and Install:**
```bash
# For macOS
curl -O https://download.swift.org/swift-6.0-branch/...
# Follow instructions at: https://www.swift.org/install/
```

Or use the Swift toolchain manager:
```bash
swiftly install latest
swiftly use latest
```

**Verify Installation:**
```bash
swift --version
# Should show Swift 6.0 or later
```

### 2. Install Android Swift SDK

```bash
# Download the Android Swift SDK
# From: https://www.swift.org/blog/nightly-swift-sdk-for-android/

# Install it
swift sdk install <path-to-android-sdk>

# Verify
swift sdk list
# Should show: aarch64-unknown-linux-android
```

### 3. Install swift-java

```bash
# Clone the repository
git clone https://github.com/swiftlang/swift-java.git
cd swift-java

# Build
swift build -c release

# Add to PATH (add to your ~/.zshrc or ~/.bashrc)
export PATH="$PATH:$(pwd)/.build/release"

# Verify
swift-java --help
```

---

## 🚀 Step-by-Step Integration

### Step 1: Build Swift Library for Android

```bash
cd QRPaymentsCore

# Build for Android ARM64
swift build \
    --swift-sdk aarch64-unknown-linux-android \
    -c release \
    --product QRPaymentsCore
```

**Expected output:**
```
Build complete! (X.XXs)
```

**Find the library:**
```bash
find .build -name "libQRPaymentsCore.so"
# Should show: .build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so
```

### Step 2: Generate JNI Bindings

```bash
# From project root
swift-java \
    --module QRPaymentsCore \
    --output QRPaymentsAndroid/app/src/main/java/com/qrpayments/bridge/generated \
    --swift-sdk aarch64-unknown-linux-android
```

**This generates:**
- `SPAYDGenerator.java` - Swift → Java wrapper
- `Validator.java` - Validation functions
- `BankAccount.java` - Data model
- JNI bridging code

### Step 3: Copy Library to Android Project

```bash
# Create directory
mkdir -p QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a

# Copy the .so file
cp QRPaymentsCore/.build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so \
   QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/

# Verify
ls -lh QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/libQRPaymentsCore.so
```

### Step 4: Update Android Gradle Configuration

Edit `QRPaymentsAndroid/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.qrpayments"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.qrpayments"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        // Add this:
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    // Add this:
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }
}
```

### Step 5: Update SwiftBridge.kt

Replace the Kotlin implementation with Swift calls:

```kotlin
package com.qrpayments.bridge

import com.qrpayments.bridge.generated.SPAYDGenerator
import com.qrpayments.bridge.generated.Validator

object SwiftBridge {
    init {
        // Load the Swift library
        System.loadLibrary("QRPaymentsCore")
    }

    /**
     * Generate SPAYD string using Swift implementation
     */
    fun generateSPAYD(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ): String {
        // Call Swift via JNI
        return SPAYDGenerator.generate(
            prefix = prefix,
            accountNumber = accountNumber,
            bankCode = bankCode,
            amount = amount,
            variableSymbol = variableSymbol,
            message = message
        )
    }

    /**
     * Validate bank code using Swift implementation
     */
    fun isValidBankCode(code: String): Boolean {
        return Validator.isValidBankCode(code)
    }

    /**
     * Validate account number using Swift implementation
     */
    fun isValidAccountNumber(number: String): Boolean {
        return Validator.isValidAccountNumber(number)
    }

    /**
     * Validate prefix using Swift implementation
     */
    fun isValidPrefix(prefix: String): Boolean {
        return Validator.isValidPrefix(prefix)
    }
}
```

### Step 6: Build and Test

```bash
cd QRPaymentsAndroid

# Sync Gradle
./gradlew --refresh-dependencies

# Clean build
./gradlew clean

# Build
./gradlew build

# Install on device
./gradlew installDebug
```

**In Android Studio:**
1. File → Sync Project with Gradle Files
2. Build → Clean Project
3. Build → Rebuild Project
4. Run ▶️

---

## 🧪 Testing

### Verify Library Loading

Add logging to SwiftBridge.kt:

```kotlin
object SwiftBridge {
    init {
        try {
            System.loadLibrary("QRPaymentsCore")
            Log.d("SwiftBridge", "✓ Swift library loaded successfully")
        } catch (e: UnsatisfiedLinkError) {
            Log.e("SwiftBridge", "❌ Failed to load Swift library", e)
            throw e
        }
    }
}
```

### Test SPAYD Generation

```kotlin
val spayd = SwiftBridge.generateSPAYD(
    prefix = "19",
    accountNumber = "2121134949",
    bankCode = "0800",
    amount = "1000.00",
    variableSymbol = null,
    message = null
)
Log.d("Test", "Generated SPAYD: $spayd")
// Expected: SPD*1.0*ACC:CZ...0800000019002121134949*AM:1000.00*CC:CZK
```

### Verify IBAN Conversion

The IBAN calculation must match between iOS and Android:

```kotlin
// Czech account: 19-2121134949/0800
// Should convert to: CZ6508000000190002121134949
// (with proper MOD 97 check digits)
```

---

## 🐛 Troubleshooting

### Error: `swift-sdk not found`

**Solution:**
```bash
swift sdk list
# If empty, install Android SDK
swift sdk install aarch64-unknown-linux-android
```

### Error: `libQRPaymentsCore.so not found`

**Check:**
```bash
# Verify file exists
ls -la QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/

# Check file type
file QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/libQRPaymentsCore.so
# Should show: ELF 64-bit LSB shared object, ARM aarch64
```

**Solution:**
- Rebuild the Swift library
- Copy to correct location
- Clean and rebuild Android project

### Error: `UnsatisfiedLinkError: dlopen failed`

**Possible causes:**
1. Wrong architecture (need ARM64)
2. Missing dependencies
3. Library not in correct location

**Solution:**
```bash
# Check Android device architecture
adb shell getprop ro.product.cpu.abi
# Should show: arm64-v8a

# Verify library is packaged in APK
unzip -l app/build/outputs/apk/debug/app-debug.apk | grep libQRPaymentsCore
```

### Error: Method signatures don't match

**Cause:** swift-java bindings out of sync with Swift code

**Solution:**
```bash
# Regenerate bindings
rm -rf QRPaymentsAndroid/app/src/main/java/com/qrpayments/bridge/generated
swift-java --module QRPaymentsCore --output ...
```

### Swift build fails

**Common issues:**
1. Android SDK not properly installed
2. Wrong Swift version
3. Missing toolchain components

**Solution:**
```bash
# Check Swift version
swift --version
# Need Swift 6.0+

# Reinstall Android SDK
swift sdk uninstall aarch64-unknown-linux-android
swift sdk install <path-to-sdk>
```

---

## 📊 Verification Checklist

Before considering integration complete:

- [ ] Swift SDK for Android installed
- [ ] swift-java tooling available
- [ ] Swift library builds for Android
- [ ] `libQRPaymentsCore.so` generated
- [ ] JNI bindings generated
- [ ] Library copied to jniLibs/arm64-v8a/
- [ ] Gradle configured for NDK
- [ ] SwiftBridge.kt updated
- [ ] App builds without errors
- [ ] App runs on device/emulator
- [ ] Library loads successfully (check LogCat)
- [ ] SPAYD generation works
- [ ] QR codes match iOS output
- [ ] All validation functions work

---

## 🎯 Success Criteria

Your integration is successful when:

1. ✅ App launches without crashes
2. ✅ SwiftBridge loads the Swift library (check LogCat)
3. ✅ SPAYD string generation works
4. ✅ Generated QR codes are identical to iOS version
5. ✅ QR codes scan successfully in Czech banking apps

---

## 📚 Additional Resources

- **Swift for Android**: https://www.swift.org/blog/nightly-swift-sdk-for-android/
- **swift-java**: https://github.com/swiftlang/swift-java
- **Examples**: https://github.com/swiftlang/swift-android-examples
- **Forums**: https://forums.swift.org/c/development/android/

---

## 💡 Tips

1. **Start with logging**: Add extensive logging to see what's happening
2. **Test incrementally**: Verify each step before moving to the next
3. **Keep Kotlin backup**: Don't delete the Kotlin implementation immediately
4. **Compare outputs**: Make sure Swift and Kotlin produce identical results
5. **Use Logcat**: Essential for debugging JNI issues

---

## 🔄 Rollback Plan

If Swift integration doesn't work, you can easily revert:

1. Restore the original `SwiftBridge.kt` with Kotlin implementation
2. Remove the `generated` folder
3. Remove `jniLibs` folder
4. Remove NDK configuration from build.gradle.kts
5. Sync and rebuild

The Kotlin implementation will work again immediately!

---

Good luck with your Swift-Android integration! 🚀🎉
