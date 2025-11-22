# Swift for Android - SUCCESSFUL Setup! 🎉

**Status:** ✅ WORKING

**Date:** November 22, 2025

## What Works

After extensive troubleshooting, we successfully built Swift code for Android using:

- **Host Swift:** Swift 6.1.3 (via swiftly)
- **Android SDK:** swift-6.1.3-RELEASE-android-24-0.1
- **Target:** aarch64-unknown-linux-android28 (ARM64 devices)
- **Library Type:** Dynamic (.so)
- **Build Tool:** `swiftly run swift build`

## Critical Success Factors

### 1. Use `swiftly run` (NOT just `swift`)

```bash
# ❌ WRONG - Uses Xcode's Swift (version mismatch)
swift build --swift-sdk aarch64-unknown-linux-android28 -c release

# ✅ CORRECT - Uses swiftly's managed Swift version
swiftly run swift build --swift-sdk aarch64-unknown-linux-android28 -c release
```

**Why this matters:** Even though `swiftly use 6.1.3` sets the project version, the `swift` command still points to Xcode's Swift. The `swiftly run` prefix ensures you're using the correct toolchain.

### 2. Version Matching is CRITICAL

Your Swift version MUST match the Android SDK version EXACTLY:

| Host Swift | Android SDK | Result |
|------------|-------------|--------|
| Xcode 6.0.3.1.10 | Swift 6.0.3 SDK (.1.2) | ❌ Version mismatch |
| Swift 6.2 | Swift 6.2 SDK | ❌ ~Copyable stdlib bugs |
| **Swift 6.1.3** | **Swift 6.1.3 SDK** | ✅ **SUCCESS!** |

### 3. Don't Use `--static-swift-stdlib` Flag

```bash
# ❌ FAILED - Missing Foundation libraries
swiftly run swift build \
  --swift-sdk aarch64-unknown-linux-android28 \
  --static-swift-stdlib \
  -c release

# ✅ SUCCESS - Dynamic linking works
swiftly run swift build \
  --swift-sdk aarch64-unknown-linux-android28 \
  -c release
```

## Complete Setup Instructions

### Prerequisites

1. macOS with Xcode installed
2. Android project set up
3. Swift package ready to build

### Step 1: Install swiftly

```bash
# Install swiftly (Swift version manager)
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash

# Reload shell
source ~/.zshrc
```

### Step 2: Install Swift 6.1.3

```bash
# Install Swift 6.1.3
swiftly install 6.1.3

# Set as active version
swiftly use 6.1.3

# Verify (note: swiftly list shows it's "in use")
swiftly list
```

### Step 3: Install Swift 6.1.3 Android SDK

```bash
# Download SDK
cd ~/Downloads
curl -L -O https://github.com/finagolfin/swift-android-sdk/releases/download/6.1.3/swift-6.1.3-RELEASE-android-24-0.1.artifactbundle.tar.gz

# Compute checksum
swift package compute-checksum swift-6.1.3-RELEASE-android-24-0.1.artifactbundle.tar.gz
# Expected: 440d09d539bda5b94807598b00696ac5d3893cb515b24715ac8868d62130b6d5

# Install SDK
swift sdk install swift-6.1.3-RELEASE-android-24-0.1.artifactbundle.tar.gz \
  --checksum 440d09d539bda5b94807598b00696ac5d3893cb515b24715ac8868d62130b6d5

# Verify ONLY ONE SDK is installed
swift sdk list
# Should show: swift-6.1.3-RELEASE-android-24-0.1
```

### Step 4: Build for Android

```bash
# Navigate to your Swift package
cd ~/Development/QRPayments/QRPaymentsCore

# Clean previous builds
rm -rf .build

# Build for ARM64 Android (most devices)
swiftly run swift build \
  --swift-sdk aarch64-unknown-linux-android28 \
  -c release

# Expected output:
# Building for production...
# [5/5] Linking libQRPaymentsCore.so
# Build complete! (2.86s)
```

### Step 5: Copy to Android Project

```bash
# Find the compiled .so file
find .build -name "*.so" -type f
# Output: .build/aarch64-unknown-linux-android28/release/libQRPaymentsCore.so

# Create jniLibs directory for ARM64
mkdir -p ~/Development/QRPayments/QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a

# Copy the library
cp .build/aarch64-unknown-linux-android28/release/libQRPaymentsCore.so \
   ~/Development/QRPayments/QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/

# Verify
ls -lh ~/Development/QRPayments/QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/
# Should show: libQRPaymentsCore.so (~190KB)
```

## Common Errors We Encountered (And Fixed!)

### Error 1: Compiler Version Mismatch

```
error: compiled module was created by a different version of the compiler
```

**Cause:** Using Xcode's Swift instead of swiftly's Swift

**Fix:** Use `swiftly run swift build` instead of just `swift build`

### Error 2: @_spi Attribute Errors

```
error: internal address accessor cannot be declared '@_spi'
```

**Cause:** Using wrong Swift version with wrong Android SDK version

**Fix:** Match versions exactly (Swift 6.1.3 + Swift 6.1.3 Android SDK)

### Error 3: Missing Foundation Libraries

```
ld.lld: error: unable to find library -lCoreFoundation
```

**Cause:** Using `--static-swift-stdlib` flag

**Fix:** Remove the flag, use dynamic linking

### Error 4: Development Snapshot Bugs

```
error: expected an identifier to name generic parameter
@frozen @safe public struct InlineArray<let count : Swift.Int, Element>
```

**Cause:** Using development snapshot (swift-DEVELOPMENT-SNAPSHOT-2025-10-17-a)

**Fix:** Use stable release versions only (6.1.3, not snapshots)

## What Didn't Work

| Approach | Issue |
|----------|-------|
| Swift 6.0.3 from Xcode | Version mismatch (.1.10 vs .1.2) |
| Swift 6.0.2 | Version mismatch |
| Swift 6.2 | ~Copyable bugs in stdlib |
| Development snapshots | Syntax errors in stdlib |
| `--static-swift-stdlib` | Missing Foundation libraries |
| Direct `swift` command | Uses Xcode Swift, not swiftly Swift |

## Architecture Mapping

Android uses different architecture names than Swift SDK:

| Android Architecture | Swift SDK Target | jniLibs Directory |
|---------------------|------------------|-------------------|
| ARM64 (most devices) | aarch64-unknown-linux-android28 | arm64-v8a |
| ARM32 | armv7-unknown-linux-android28 | armeabi-v7a |
| x86_64 (emulators) | x86_64-unknown-linux-android28 | x86_64 |

We built for ARM64 only, which covers 99%+ of modern Android devices.

## Next Steps (Future Work)

The Swift library is now built and copied to your Android project. To actually use it, you'll need to:

1. **Generate JNI bindings** using swift-java or similar tool
2. **Update SwiftBridge.kt** to call native Swift functions via JNI
3. **Configure build.gradle.kts** with NDK settings
4. **Test in Android Studio**

For now, your Kotlin bridge implementation works perfectly and is production-ready. You can continue using that while Swift for Android matures.

## Lessons Learned

1. **Swift for Android is experimental** - Expect rough edges
2. **Version matching is critical** - Use exact same versions
3. **swiftly is essential** - Don't rely on Xcode's Swift
4. **Dynamic linking works better** - Avoid static stdlib flag
5. **Documentation gaps exist** - Official docs miss key details like `swiftly run`

## Resources

- **swiftly:** https://github.com/swiftlang/swiftly
- **Swift Android SDKs:** https://github.com/finagolfin/swift-android-sdk/releases
- **Official Guide:** https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html
- **Swift Forums:** https://forums.swift.org/c/development/android/

## Reproducible Build Command

Save this for future builds:

```bash
#!/bin/bash
# Build QRPaymentsCore for Android (ARM64)

cd ~/Development/QRPayments/QRPaymentsCore

# Ensure Swift 6.1.3 is active
swiftly use 6.1.3

# Clean build
rm -rf .build

# Build for Android ARM64
swiftly run swift build \
  --swift-sdk aarch64-unknown-linux-android28 \
  -c release

# Copy to Android project
cp .build/aarch64-unknown-linux-android28/release/libQRPaymentsCore.so \
   ~/Development/QRPayments/QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/

echo "✅ Build complete! Library copied to Android project."
```

---

**Conclusion:** Swift for Android DOES work, but requires careful setup and version matching. Our success proves it's possible! 🎉
