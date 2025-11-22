# Build Fix Notes

## Issues Encountered

When running `./build-swift-android.sh`, you encountered two build errors:

### Error 1: JNI Headers Not Found
```
fatal error: 'jni.h' file not found
   18 | #include <jni.h>
```

**Root Cause:** The `swift-java` package was added as a dependency in `Package.swift`. When building for Android, swift-java tries to compile its C++ JNI support code, but it can't find the JNI headers because:
- We're cross-compiling from macOS to Android
- JNI headers aren't in the standard macOS SDK location
- swift-java expects to run on an actual Android system or with Android NDK configured

### Error 2: -static-stdlib No Longer Supported
```
error: -static-stdlib is no longer supported for Apple platforms
```

**Root Cause:** The `-Xswiftc -static-stdlib` flag in the build script is deprecated and removed in Swift 6.2 for macOS platforms.

---

## Why We Don't Need swift-java

The `swift-java` project serves a different purpose than what we need:

| Tool | Purpose | Direction |
|------|---------|-----------|
| **swift-java** | Call Java APIs from Swift code | Swift → Java |
| **Our JNI Bridge** | Call Swift APIs from Kotlin code | Kotlin → Swift |

### What swift-java Does:
```swift
// Swift code calling Java
import JavaKit

let javaString = JavaString("Hello from Java!")
javaString.toLowerCase()  // Calling Java method from Swift
```

### What We're Doing:
```kotlin
// Kotlin code calling Swift
object SwiftBridge {
    external fun nativeGenerateSPAYD(...): String  // Calls Swift via JNI
}
```

---

## Our Manual JNI Approach

We're using a **manual JNI bridge** which is more appropriate for Kotlin → Swift calls:

```
┌─────────────────────────────────────────────┐
│         Kotlin (Android App)                │
│                                             │
│  SwiftBridge.nativeGenerateSPAYD(...)      │
│         ↓ JNI external function             │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│    C JNI Wrapper (swift_jni_bridge.c)      │
│                                             │
│  Java_..._nativeGenerateSPAYD(...) {        │
│      char* result =                         │
│        Swift_QRPaymentsCore_generateSPAYD(  │
│            ...                              │
│        );                                   │
│  }                                          │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  Swift Library (QRPaymentsCore)            │
│                                             │
│  @_cdecl("Swift_QRPaymentsCore_...")        │
│  public func Swift_..._generateSPAYD(...)   │
│      -> UnsafeMutablePointer<CChar>? {      │
│      let result = SPAYDGenerator.generate(  │
│          ...                                │
│      )                                      │
│      return strdup(result)                  │
│  }                                          │
└─────────────────────────────────────────────┘
```

### Advantages of Manual JNI:
1. **No swift-java dependency** → Simpler build, fewer dependencies
2. **Full control** → We define exact JNI interface
3. **C-compatible** → Works with any JNI-capable language
4. **Portable** → No JDK architecture requirements
5. **Standard approach** → Well-documented, widely used pattern

---

## Fixes Applied

### Fix 1: Removed swift-java Dependency

**File:** `QRPaymentsCore/Package.swift`

**Before:**
```swift
dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java.git", branch: "main")
],
targets: [
    .target(
        name: "QRPaymentsCore",
        dependencies: [
            .product(name: "SwiftJava", package: "swift-java"),
            .product(name: "JavaTypes", package: "swift-java"),
        ],
```

**After:**
```swift
dependencies: [
    // No external dependencies needed
    // We use manual JNI bridge via @_cdecl exports (see JavaBridge.swift)
],
targets: [
    .target(
        name: "QRPaymentsCore",
        dependencies: [],
```

### Fix 2: Removed -static-stdlib Flag

**File:** `build-swift-android.sh`

**Before:**
```bash
swiftly run swift build \
    -c debug \
    --triple aarch64-unknown-linux-android28 \
    --product QRPaymentsCore \
    -Xswiftc -static-stdlib
```

**After:**
```bash
swiftly run swift build \
    -c debug \
    --triple aarch64-unknown-linux-android28 \
    --product QRPaymentsCore
```

### Fix 3: Added Clean Step

**File:** `build-swift-android.sh`

Added before build:
```bash
# Clean previous build artifacts to ensure fresh build
if [ -d ".build" ]; then
    echo "🧹 Cleaning previous build artifacts..."
    rm -rf .build
fi
```

This ensures no old swift-java artifacts interfere with the new build.

---

## Verification

After pulling the latest changes and running `./build-swift-android.sh`, you should see:

```
🚀 Building Swift library for Android ARM64...

🧹 Cleaning previous build artifacts...
📦 Building with Swift 6.2 Android SDK...
Building for debugging...
[1/1] Compiling QRPaymentsCore ...
Build complete! (X.XXs)
✅ Found library: .build/aarch64-unknown-linux-android28/debug/libQRPaymentsCore.so
-rw-r--r-- ... 5.9M ... libQRPaymentsCore.so
📦 Copying to Android project...
✅ Library copied to: ../QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a/libQRPaymentsCore.so
```

**No errors about:**
- ❌ `jni.h` not found
- ❌ `-static-stdlib` not supported

---

## Summary

| Issue | Cause | Fix |
|-------|-------|-----|
| `jni.h` not found | swift-java dependency trying to build | Removed swift-java from Package.swift |
| `-static-stdlib` error | Deprecated flag on macOS | Removed flag from build script |
| Stale artifacts | Old swift-java build cache | Added clean step to build script |

The integration now uses a **clean, manual JNI approach** without unnecessary dependencies!
