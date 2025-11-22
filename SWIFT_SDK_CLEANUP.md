# Swift SDK Cleanup Guide

## Issue: Multiple SDK Installations

You're seeing warnings like:
```
warning: multiple Swift SDKs match ID `swift-6.2-RELEASE-android-24-0.1`
```

This means you have duplicate SDK installations, likely from:
1. Installing the same SDK multiple times
2. Both the old development snapshot AND the new 6.2 release

## Quick Fix: Clean Up Duplicates

### Step 1: List All Installed SDKs

```bash
swift sdk list
```

You'll likely see duplicates like:
```
swift-DEVELOPMENT-SNAPSHOT-2025-10-17-a-android-0.1
swift-6.2-RELEASE-android-24-0.1
swift-6.2-RELEASE-android-24-0.1  (duplicate)
```

### Step 2: Remove Old/Duplicate SDKs

**Remove the development snapshot (the one causing your original errors):**

```bash
swift sdk remove swift-DEVELOPMENT-SNAPSHOT-2025-10-17-a-android-0.1
```

**If you see multiple entries with the same name, you need to manually clean up:**

```bash
# Remove ALL Swift SDKs for Android
rm -rf ~/Library/org.swift.swiftpm/swift-sdks/*android*

# Verify they're gone
swift sdk list
```

### Step 3: Reinstall Clean Copy

Now install a fresh copy of the 6.2 SDK:

```bash
# Install Swift 6.2 SDK for Android (clean installation)
swift sdk install \
  https://github.com/finagolfin/swift-android-sdk/releases/download/6.2/swift-6.2-RELEASE-android-24-0.1.artifactbundle.tar.gz \
  --checksum c26ebfd4e32c0ca1beabcc45729b62042da57ee76d7d043f63f2235da90dc491

# Verify - should see ONLY ONE entry
swift sdk list
```

Expected output:
```
swift-6.2-RELEASE-android-24-0.1
```

### Step 4: Clean Build Directory

```bash
cd ~/Development/QRPayments/QRPaymentsCore
rm -rf .build

# Try building again
swift build --swift-sdk swift-6.2-RELEASE-android-24-0.1 -c release
```

## Alternative: Use SDK Path Instead of Name

If you still have issues with SDK naming, you can reference the SDK by its full path:

```bash
# Find the SDK path
ls -la ~/Library/org.swift.swiftpm/swift-sdks/

# Build using full path
swift build \
  --swift-sdk ~/Library/org.swift.swiftpm/swift-sdks/swift-6.2-RELEASE-android-24-0.1.artifactbundle \
  -c release
```

## Verification

After cleanup, verify:

```bash
# Should show ONLY ONE Android SDK
swift sdk list

# Should NOT show development snapshots
swift sdk list | grep SNAPSHOT
# (should return nothing)

# Build should work without warnings
cd QRPaymentsCore
swift build --swift-sdk swift-6.2-RELEASE-android-24-0.1 -c release
```

## Common Cleanup Scenarios

### Scenario 1: Multiple versions of same SDK

```bash
# List all
swift sdk list

# Remove specific ones
swift sdk remove swift-6.2-RELEASE-android-24-0.1  # Run multiple times if needed
```

### Scenario 2: Can't remove via command

```bash
# Nuclear option - remove all Android SDKs
rm -rf ~/Library/org.swift.swiftpm/swift-sdks/*android*
rm -rf ~/Library/org.swift.swiftpm/swift-sdks/*DEVELOPMENT*

# Reinstall fresh
swift sdk install <URL>
```

### Scenario 3: SDK corruption

```bash
# Remove everything
rm -rf ~/Library/org.swift.swiftpm/swift-sdks/

# Reinstall only what you need
swift sdk install <URL>
```

## After Cleanup

Once you have a clean SDK installation:

1. ✅ Only ONE Android SDK should be listed
2. ✅ NO development snapshots
3. ✅ Build should work without "multiple Swift SDKs" warnings
4. ✅ Integration script should run cleanly

## Prevention

To avoid this in the future:

1. **Don't install multiple times** - Check `swift sdk list` before installing
2. **Remove old before installing new** - Clean up when upgrading
3. **Avoid development snapshots** - Use stable releases only
4. **Use checksums** - Verify downloads before installing

## Need Help?

If you still see issues after cleanup:

1. Show output of `swift sdk list`
2. Show output of `ls -la ~/Library/org.swift.swiftpm/swift-sdks/`
3. Check for permission issues on the SDK directory

---

**TL;DR:**
```bash
# Clean slate
rm -rf ~/Library/org.swift.swiftpm/swift-sdks/*android*

# Fresh install
swift sdk install https://github.com/finagolfin/swift-android-sdk/releases/download/6.2/swift-6.2-RELEASE-android-24-0.1.artifactbundle.tar.gz --checksum c26ebfd4e32c0ca1beabcc45729b62042da57ee76d7d043f63f2235da90dc491

# Verify
swift sdk list  # Should show ONLY ONE Android SDK

# Build
cd QRPaymentsCore
rm -rf .build
swift build --swift-sdk swift-6.2-RELEASE-android-24-0.1 -c release
```
