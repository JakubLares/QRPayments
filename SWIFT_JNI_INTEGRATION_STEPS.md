# Swift JNI Integration - Final Steps

## Current Status ✅

We've successfully set up the JNI bridge infrastructure:

- ✅ Swift 6.2 @_cdecl exports in `JavaBridge.swift`
- ✅ C JNI wrapper in `swift_jni_bridge.c`
- ✅ CMakeLists.txt configured for Android NDK
- ✅ SwiftBridge.kt ready to load native library
- ✅ build.gradle.kts configured with CMake

## Missing Piece 🔴

The **Swift library (libQRPaymentsCore.so) is not in the Android project**. Without it, CMake cannot build the JNI bridge.

## Solution: Build and Copy Swift Library

### On Your Mac (where you have Swift 6.2 installed):

```bash
# Navigate to project root
cd ~/Development/QRPayments

# Run the build script
./build-swift-android.sh
```

This script will:
1. Build `libQRPaymentsCore.so` using Swift 6.2 Android SDK
2. Copy it to `QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/`
3. Show you the file size (should be ~5-6 MB)

### Verify the Library

```bash
# Check that the file exists and has reasonable size
ls -lh QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/libQRPaymentsCore.so
```

Expected output: `-rw-r--r-- 1 user staff 5.9M Nov 22 ... libQRPaymentsCore.so`

## How the Integration Works

```
┌─────────────────────────────────────────────────────────────┐
│                    Android App (Kotlin)                      │
│                                                              │
│  SwiftBridge.kt                                             │
│    ↓ System.loadLibrary("qrpaymentsbridge")                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  libqrpaymentsbridge.so (C JNI Bridge)                 │ │
│  │                                                         │ │
│  │  swift_jni_bridge.c                                    │ │
│  │    ↓ Calls Swift @_cdecl functions                     │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │  libQRPaymentsCore.so (Swift Library)            │  │ │
│  │  │                                                   │  │ │
│  │  │  JavaBridge.swift                                 │  │ │
│  │  │    - Swift_QRPaymentsCore_generateSPAYD()        │  │ │
│  │  │    - Swift_QRPaymentsCore_convertToIBAN()        │  │ │
│  │  │                                                   │  │ │
│  │  │  SPAYDGenerator.swift                            │  │ │
│  │  │    - Core Swift implementation                    │  │ │
│  │  └──────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Build Process

### 1. Swift Build (on Mac)
```bash
swiftly run swift build \
    --triple aarch64-unknown-linux-android28 \
    --product QRPaymentsCore
```
**Produces:** `.build/aarch64-unknown-linux-android28/debug/libQRPaymentsCore.so`

### 2. Copy to Android Project
```bash
cp libQRPaymentsCore.so \
   QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/
```

### 3. Android Gradle Build (Android Studio)
When you build the Android app, Gradle will:
1. Find `CMakeLists.txt` via `externalNativeBuild`
2. Run CMake to compile `swift_jni_bridge.c`
3. Link it against `libQRPaymentsCore.so` (IMPORTED library)
4. Produce `libqrpaymentsbridge.so` in `build/intermediates/cmake/debug/obj/arm64-v8a/`

### 4. App Loads Libraries
```kotlin
System.loadLibrary("qrpaymentsbridge") // Automatically loads libQRPaymentsCore.so too
```

## Testing After Build

### 1. Check Logcat for Success Message
```
SwiftBridge: ✅ JNI bridge loaded successfully!
SwiftBridge: 🚀 Calling Swift implementation via JNI
```

### 2. If You See Fallback Message
```
SwiftBridge: ⚠️ JNI bridge not available, using Kotlin fallback
```

**This means:**
- Either `libQRPaymentsCore.so` is missing
- Or CMake failed to build `libqrpaymentsbridge.so`

### 3. Verify Both Libraries Exist

After building in Android Studio:
```bash
# Swift library (you copy manually)
ls -lh QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/libQRPaymentsCore.so

# JNI bridge (built by CMake)
ls -lh QRPaymentsAndroid/app/build/intermediates/cmake/debug/obj/arm64-v8a/libqrpaymentsbridge.so
```

## Troubleshooting

### Problem: CMake Can't Find Swift Library
**Error:** `CMake Error: swift-lib set to NOTFOUND`

**Solution:** The Swift library doesn't exist. Run `./build-swift-android.sh` on your Mac.

### Problem: JNI Bridge Not Building
**Check:** Android Studio Build Output for CMake errors

```
Build → Rebuild Project
```

Look for:
```
> Task :app:configureCMakeDebug[arm64-v8a]
> Task :app:buildCMakeDebug[arm64-v8a]
```

### Problem: UnsatisfiedLinkError
**Error:** `java.lang.UnsatisfiedLinkError: dlopen failed`

**Possible causes:**
1. Missing dependency library (Swift stdlib, etc.)
2. Architecture mismatch
3. Library not in correct location

**Check:** Use `adb shell` to examine the library:
```bash
adb shell "ls -l /data/app/com.qrpayments-*/lib/arm64/"
```

## Next Steps

1. **Run `./build-swift-android.sh`** on your Mac to build and copy the Swift library
2. **Commit the .so file** (or add to .gitignore if it's too large)
3. **Open Android Studio** and rebuild the project
4. **Check logcat** for JNI bridge success message
5. **Test SPAYD generation** and verify it's using Swift implementation

## Files Modified

- `QRPaymentsCore/Sources/QRPaymentsCore/JavaBridge.swift` - @_cdecl exports
- `QRPaymentsAndroid/app/src/main/cpp/swift_jni_bridge.c` - JNI wrapper
- `QRPaymentsAndroid/app/src/main/cpp/CMakeLists.txt` - CMake config
- `QRPaymentsAndroid/app/build.gradle.kts` - NDK/CMake setup
- `QRPaymentsAndroid/app/src/main/java/com/qrpayments/bridge/SwiftBridge.kt` - Library loading

## References

- [Swift @_cdecl Documentation](https://github.com/swiftlang/swift/blob/main/docs/CToSwiftNameTranslation.md)
- [Android NDK CMake Guide](https://developer.android.com/ndk/guides/cmake)
- [JNI Specification](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/jniTOC.html)
