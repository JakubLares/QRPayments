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

#### Step 3: Install Swift SDK for Android

**Important:** As of late 2024/early 2025, there is NO official stable release yet.
Swift SDK for Android is in preview status. The best option is to use community builds.

**Option A: Install from finagolfin's releases (Recommended)**

```bash
# Install Swift 6.2 SDK for Android (most stable community build)
swift sdk install \
  https://github.com/finagolfin/swift-android-sdk/releases/download/6.2/swift-6.2-RELEASE-android-24-0.1.artifactbundle.tar.gz \
  --checksum c26ebfd4e32c0ca1beabcc45729b62042da57ee76d7d043f63f2235da90dc491

# Verify installation
swift sdk list
# Should show: swift-6.2-RELEASE-android-24-0.1
```

**Option B: Download then install locally**

```bash
# Download the artifact bundle
wget https://github.com/finagolfin/swift-android-sdk/releases/download/6.2/swift-6.2-RELEASE-android-24-0.1.artifactbundle.tar.gz

# Verify checksum
sha256sum swift-6.2-RELEASE-android-24-0.1.artifactbundle.tar.gz
# Expected: c26ebfd4e32c0ca1beabcc45729b62042da57ee76d7d043f63f2235da90dc491

# Install the local file
swift sdk install swift-6.2-RELEASE-android-24-0.1.artifactbundle.tar.gz
```

**Check available versions:**
- https://github.com/finagolfin/swift-android-sdk/releases

**What SDK name to use when building:**

After installation, get the exact SDK name:
```bash
swift sdk list
```

You'll see something like:
- `swift-6.2-RELEASE-android-24-0.1` (use this in build commands)

NOT:
- `aarch64-unknown-linux-android` (this is the architecture, not the SDK name)

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
| Swift SDK for Android | Swift 6.2 from finagolfin/swift-android-sdk |
| Android NDK | 25.x or 26.x |
| Android minSdk | 24 (matches SDK) |
| Android targetSdk | 34 |

**Reality Check:** Swift for Android is still in preview. Even the "best" builds are experimental.
Expect issues and be ready to fall back to the Kotlin bridge implementation if needed.

## Additional Resources

- **Swift Downloads**: https://www.swift.org/install/
- **Swift SDK for Android (Community Builds)**: https://github.com/finagolfin/swift-android-sdk
- **Swift for Android Official Guide**: https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html
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
