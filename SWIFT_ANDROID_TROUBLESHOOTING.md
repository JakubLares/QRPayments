# Swift Android Integration - Troubleshooting Guide

## Critical Issue: Development Snapshot Errors

### Problem

If you see errors like this when running `./integrate-swift-android.sh`:

```
error: expected an identifier to name generic parameter
@frozen @safe public struct InlineArray<let count : Swift.Int, Element>
                                        ^
```

Or warnings like:

```
warning: no such SDK: /Users/.../swift-DEVELOPMENT-SNAPSHOT-2025-10-17-a-android...
warning: libc not found for 'x86_64-unknown-linux-android36'
```

### Root Cause

You are using a **development snapshot** of Swift (e.g., `swift-DEVELOPMENT-SNAPSHOT-2025-10-17-a`).

**Development snapshots are unstable and often contain bugs**, including syntax errors in the Swift standard library itself. The `InlineArray` type in this snapshot uses invalid Swift syntax for generic parameters.

### Solution: Install Stable Swift 6.0+

#### Step 1: Remove Development Snapshot

```bash
# List installed Swift SDKs
swift sdk list

# Remove the development snapshot
swift sdk remove <snapshot-name>
```

Example:
```bash
swift sdk remove swift-DEVELOPMENT-SNAPSHOT-2025-10-17-a-android-0.1
```

#### Step 2: Install Stable Swift 6.0

**Option A: Using swiftly (Recommended)**

```bash
# Install swiftly (Swift version manager)
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash

# Install latest stable Swift
swiftly install latest

# Use the stable version
swiftly use latest

# Verify
swift --version
# Should show: Swift version 6.0.x (or later)
```

**Option B: Manual Download**

1. Go to https://www.swift.org/install/
2. Download **Swift 6.0** or later (NOT a development snapshot)
3. Install according to platform instructions
4. Verify: `swift --version`

#### Step 3: Install Stable Swift SDK for Android

```bash
# Download stable Swift SDK for Android from:
# https://www.swift.org/install/

# For example (check latest stable version):
# https://download.swift.org/swift-6.0-release/...

# Install the SDK
swift sdk install <path-to-stable-android-sdk>

# Verify installation
swift sdk list
# Should show: aarch64-unknown-linux-android (without "DEVELOPMENT-SNAPSHOT")
```

#### Step 4: Rebuild Your Project

```bash
# Clean previous builds
cd QRPaymentsCore
rm -rf .build

# Run integration script
cd ..
./integrate-swift-android.sh
```

## Common Android SDK Issues

### Issue 1: Wrong Android API Level

**Error:**
```
warning: libc not found for 'x86_64-unknown-linux-android36'
```

**Cause:** The SDK is targeting Android API level 36, which may not exist or be properly configured.

**Solution:**
- Use a stable Swift SDK that targets API level 24-34
- Ensure your Android project's `minSdk` matches (recommended: 26)

### Issue 2: SDK Path Not Found

**Error:**
```
warning: no such SDK: /Users/.../swift-sdks/...
```

**Cause:** Swift SDK installation is incomplete or corrupted.

**Solution:**

```bash
# Remove and reinstall the SDK
swift sdk remove <sdk-name>
swift sdk install <path-to-sdk>

# Verify paths
swift sdk list
swift sdk show <sdk-name>
```

### Issue 3: Missing NDK or Toolchain

**Error:**
```
error: unable to find library 'c' for target 'aarch64-unknown-linux-android'
```

**Cause:** Android NDK not properly linked in Swift SDK.

**Solution:**

1. Install Android NDK via Android Studio
2. Set environment variable:
   ```bash
   export ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk/<version>"
   ```
3. Verify NDK path in Swift SDK configuration

## Package.swift Configuration

The updated `Package.swift` now includes:

1. **Swift 6.0 requirement:**
   ```swift
   // swift-tools-version: 6.0
   ```

2. **Linux platform support:**
   ```swift
   platforms: [
       .iOS(.v17),
       .macOS(.v14),
       .linux  // For Android
   ]
   ```

3. **Dynamic library type:**
   ```swift
   .library(
       name: "QRPaymentsCore",
       type: .dynamic,  // Required for JNI
       targets: ["QRPaymentsCore"]
   )
   ```

## Build Verification

### Verify Swift Installation

```bash
# Check Swift version (should be 6.0+, NOT a snapshot)
swift --version

# List installed SDKs
swift sdk list

# Should see something like:
# aarch64-unknown-linux-android
# (NOT: swift-DEVELOPMENT-SNAPSHOT-...)
```

### Verify SDK Compatibility

```bash
# Show SDK details
swift sdk show aarch64-unknown-linux-android

# Ensure it shows:
# - Valid NDK path
# - API level 24-34 (not 36)
# - Proper toolchain paths
```

### Test Build

```bash
cd QRPaymentsCore

# Clean build directory
rm -rf .build

# Try building for Android
swift build --swift-sdk aarch64-unknown-linux-android -c release

# Should complete without errors
# Look for: Build complete!
```

## Integration Script Improvements

The updated `integrate-swift-android.sh` now:

1. ✅ Detects development snapshots and warns you
2. ✅ Provides guidance on using stable releases
3. ✅ Allows you to cancel if using unstable SDK

When you run the script, you'll see:

```
⚠️  WARNING: You are using a development snapshot!
   Development snapshots may be unstable and contain bugs.

If you encounter build errors (especially in Swift standard library):
1. Download a STABLE Swift 6.0+ release from https://www.swift.org/install/
2. Install a stable Swift SDK for Android
3. Avoid using nightly/development snapshots for production builds

Continue with development snapshot anyway? (y/n)
```

## Recommended Setup

For the most stable experience:

| Component | Recommended Version |
|-----------|---------------------|
| Swift | 6.0+ (stable release) |
| Swift SDK for Android | Stable 6.0+ release |
| Android NDK | 25.x or 26.x |
| Android minSdk | 26 |
| Android targetSdk | 34 |

## Additional Resources

- **Swift Downloads**: https://www.swift.org/install/
- **Swift for Android Blog**: https://www.swift.org/blog/nightly-swift-sdk-for-android/
- **Swift Forums (Android)**: https://forums.swift.org/c/development/android/
- **swift-android-examples**: https://github.com/swiftlang/swift-android-examples

## Still Having Issues?

If you continue to have problems after following this guide:

1. **Check Swift Forums**: Search for similar errors
2. **Verify NDK installation**: Ensure Android NDK is properly installed
3. **Try minimal example**: Test with swift-android-examples first
4. **Report the issue**: Provide full error logs and Swift version info

## Quick Fix Checklist

- [ ] Remove development snapshot Swift SDK
- [ ] Install stable Swift 6.0+
- [ ] Install stable Swift SDK for Android (not snapshot)
- [ ] Verify: `swift --version` shows stable release
- [ ] Verify: `swift sdk list` shows no "DEVELOPMENT-SNAPSHOT"
- [ ] Clean build directory: `rm -rf QRPaymentsCore/.build`
- [ ] Run: `./integrate-swift-android.sh`
- [ ] Build should complete successfully

---

**Remember:** Development snapshots are for testing bleeding-edge Swift features, not for production builds. Always use stable releases for your applications.
