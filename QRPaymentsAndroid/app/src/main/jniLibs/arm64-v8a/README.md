# Swift Library Location

This directory should contain the Swift library built for Android ARM64:

```
libQRPaymentsCore.so
```

## Why is the library missing?

The Swift library must be built on a machine with Swift 6.2+ and the Swift Android SDK installed. This cannot be done in the CI/CD container environment.

## How to build the library

From the project root, run:

```bash
./build-swift-android.sh
```

This will:
1. Build `libQRPaymentsCore.so` using Swift 6.2 for Android ARM64
2. Copy it to this directory
3. Display the file size (~5-6 MB)

## Verification

After running the build script, verify:

```bash
ls -lh libQRPaymentsCore.so
```

Expected: `-rw-r--r-- ... 5.9M ... libQRPaymentsCore.so`

## What happens without this library?

Without `libQRPaymentsCore.so`:
- CMake cannot build the JNI bridge (`libqrpaymentsbridge.so`)
- The app will fall back to the Kotlin implementation
- You'll see this in logcat:
  ```
  SwiftBridge: ⚠️ JNI bridge not available, using Kotlin fallback
  ```

## See Also

- `../../../../../../SWIFT_JNI_INTEGRATION_STEPS.md` - Complete integration guide
- `../../../../../../build-swift-android.sh` - Build script
