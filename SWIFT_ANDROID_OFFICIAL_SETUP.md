# Swift for Android - Official Setup Guide

**⚠️ WARNING:** This is the "correct" official approach, but it's very complex. See RECOMMENDATION.md for why you should use Kotlin instead.

## Overview

According to https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html:

> **"The host toolchain and the Swift SDK versions must match exactly."**

This means you **cannot use Xcode's Swift**. You must install a specific Swift toolchain that matches the Android SDK.

## Why We Had Compiler Errors

```
error: compiled module was created by a different version of the compiler
```

**Root cause:**
- Your Xcode Swift: `Swift version 6.0.x (from Xcode 16.2.0)`
- Android SDK: Built with `Swift version X.Y.Z (different version)`
- **They don't match** → Error

## Prerequisites

1. **swiftly** (Swift version manager)
2. **Matching Swift snapshot toolchain**
3. **Android NDK 27d** (specific version)
4. **Time and patience** (5-10 hours)

## Step 1: Install swiftly

```bash
# Install swiftly (Swift version manager)
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

## Step 2: Find Matching Swift Version

You need to find which Swift version the Android SDK was built with.

### For finagolfin's Swift 6.0.3 SDK:

Check the release notes: https://github.com/finagolfin/swift-android-sdk/releases/tag/6.0.3

The SDK was built with a specific Swift snapshot. You need to install **that exact snapshot**.

### Example (if it was built with Swift 6.0.3-RELEASE):

```bash
# Install the matching Swift toolchain
swiftly install 6.0.3

# Switch to it
swiftly use 6.0.3

# Verify
swift --version
# Should show: Swift version 6.0.3
```

### For snapshot builds:

```bash
# If the SDK was built with a snapshot (like main-snapshot-2025-10-16)
swiftly install main-snapshot-2025-10-16
swiftly use main-snapshot-2025-10-16
```

## Step 3: Install Android NDK 27d

The SDK specifically requires **Android NDK version 27d**.

```bash
# Download NDK 27d from:
# https://developer.android.com/ndk/downloads

# Extract it
unzip android-ndk-r27d-darwin.zip
sudo mv android-ndk-r27d /Library/Android/ndk/27d

# Set environment variable
export ANDROID_NDK_HOME=/Library/Android/ndk/27d

# Add to ~/.zshrc to make permanent
echo 'export ANDROID_NDK_HOME=/Library/Android/ndk/27d' >> ~/.zshrc
```

## Step 4: Install Swift SDK for Android

Now that you have matching Swift version:

```bash
# Download the SDK
cd ~/Downloads
curl -L -O https://github.com/finagolfin/swift-android-sdk/releases/download/6.0.3/swift-6.0.3-RELEASE-android-24-0.1.artifactbundle.tar.gz

# Compute checksum
swift package compute-checksum swift-6.0.3-RELEASE-android-24-0.1.artifactbundle.tar.gz

# Install with checksum
swift sdk install swift-6.0.3-RELEASE-android-24-0.1.artifactbundle.tar.gz --checksum [CHECKSUM]

# Verify
swift sdk list
```

## Step 5: Build for Android

**Important:** Use the `--static-swift-stdlib` flag (we missed this before!)

```bash
cd ~/Development/QRPayments/QRPaymentsCore

# Clean build
rm -rf .build

# Build for ARM64 (most Android devices)
swift build \
  --swift-sdk aarch64-unknown-linux-android28 \
  --static-swift-stdlib \
  -c release

# Or for x86_64 (emulators)
swift build \
  --swift-sdk x86_64-unknown-linux-android28 \
  --static-swift-stdlib \
  -c release
```

## Step 6: Find the .so file

```bash
# Should be in .build/aarch64-unknown-linux-android/release/
find .build -name "*.so" -type f
```

## Step 7: Copy to Android project

```bash
# Create jniLibs directory
mkdir -p ~/Development/QRPayments/QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a

# Copy the .so file
cp .build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so \
   ~/Development/QRPayments/QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/
```

## Gotchas and Issues

### Issue 1: Can't Use Xcode's Swift Anymore

Once you switch to a snapshot toolchain:
- ❌ Xcode may not work properly
- ❌ iOS development affected
- ⚠️ Need to switch back and forth with `swiftly use`

```bash
# For iOS development (use Xcode's Swift)
swiftly use swift  # or whatever your Xcode version is

# For Android development (use snapshot)
swiftly use 6.0.3  # or your snapshot version
```

### Issue 2: Version Drift

When you update Xcode:
- Your iOS Swift version changes
- Android SDK version stays the same
- Need to manage two Swift versions forever

### Issue 3: Snapshot Instability

Snapshot toolchains are:
- ❌ Not production-tested
- ❌ May have bugs
- ❌ Can break between snapshots

### Issue 4: Build Complexity

Every time you build for Android:
1. Switch to snapshot Swift (`swiftly use`)
2. Build with correct flags
3. Copy .so file
4. Switch back to Xcode Swift
5. Repeat

## Verification

After all this setup:

```bash
# Check Swift version matches
swift --version

# Check Android SDK installed
swift sdk list

# Check NDK installed
ls -la $ANDROID_NDK_HOME

# Try building
cd ~/Development/QRPayments/QRPaymentsCore
swift build --swift-sdk aarch64-unknown-linux-android28 --static-swift-stdlib -c release
```

If you still get compiler errors, the versions still don't match!

## Estimated Time Investment

- **Initial setup:** 2-4 hours
- **Troubleshooting:** 3-6 hours
- **Learning curve:** 5-10 hours
- **Ongoing maintenance:** 1-2 hours per update

**Total: 10-20 hours** to get working, then ongoing complexity.

## Alternative: Use Kotlin (5 minutes)

Your Kotlin implementation:
- ✅ Already works
- ✅ Zero setup
- ✅ No version management
- ✅ Production-ready

```bash
cd ~/Development/QRPayments/QRPaymentsAndroid
./gradlew build
# Done! 🎉
```

## Conclusion

The official Swift for Android setup is:
- ✅ Technically correct
- ✅ Will work if done right
- ❌ Very complex
- ❌ Time-consuming
- ❌ Ongoing maintenance burden
- ❌ Still experimental

**For a simple payment app, this is massive overkill.**

**Recommendation:** Use the Kotlin bridge. Revisit Swift in 12 months when it's stable and mature.

See **RECOMMENDATION.md** for the practical approach.
