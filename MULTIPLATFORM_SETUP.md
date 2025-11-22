# Multiplatform Swift Setup (macOS → iOS + Android)

## Your Setup

You're developing a **multiplatform Swift project** on **macOS** that runs on:
- ✅ **iOS** (native)
- ✅ **Android** (via cross-compilation)

## Platform Architecture Explained

### Development Environment: macOS (Your Mac)

- **Where you code**: macOS (arm64-apple-macosx or x86_64-apple-macosx)
- **Tools installed**: Xcode, Swift toolchain, Android SDK for Swift
- **Build happens**: On your Mac

### Target Platforms

| Platform | Kernel | Swift Platform | Build From |
|----------|--------|----------------|------------|
| **iOS** | Darwin (XNU) | `.iOS` | macOS (native) |
| **macOS** | Darwin (XNU) | `.macOS` | macOS (native) |
| **Android** | Linux | `.linux` | macOS (cross-compile) |

### Why `.linux` for Android?

Android uses the **Linux kernel**, so Swift treats Android as a Linux target:
- Android OS = Linux kernel + Android userspace
- Swift SDK for Android = Swift toolchain for Linux (Android variant)
- When you cross-compile for Android, you're building for `aarch64-unknown-linux-android`

**Important:** You're NOT running Linux on your Mac. You're building FOR Linux (Android) FROM macOS.

## Your Workflow

```
┌─────────────────────────────────────────────────────┐
│         Your Mac (arm64-apple-macosx)               │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         QRPaymentsCore (Swift)              │   │
│  │         Shared Business Logic               │   │
│  └─────────────────────────────────────────────┘   │
│                      │                              │
│                      │                              │
│         ┌────────────┴────────────┐                 │
│         │                         │                 │
│         ▼                         ▼                 │
│  ┌─────────────┐          ┌─────────────┐          │
│  │  Build for  │          │  Build for  │          │
│  │    iOS      │          │   Android   │          │
│  │  (native)   │          │(cross-comp) │          │
│  └─────────────┘          └─────────────┘          │
│         │                         │                 │
└─────────┼─────────────────────────┼─────────────────┘
          │                         │
          ▼                         ▼
    ┌──────────┐            ┌──────────────┐
    │   iOS    │            │   Android    │
    │  Device  │            │    Device    │
    │          │            │ (Linux-based)│
    └──────────┘            └──────────────┘
```

## SDK Locations (macOS Paths)

All Swift SDK files are stored in macOS-specific locations:

### Swift SDKs Directory

```bash
~/Library/org.swift.swiftpm/swift-sdks/
```

This is where your Swift SDK for Android is installed:
```
~/Library/org.swift.swiftpm/swift-sdks/
└── swift-6.2-RELEASE-android-24-0.1.artifactbundle/
    └── swift-6.2-release-android-24-sdk/
```

### Xcode Toolchains (if using Xcode)

```bash
/Applications/Xcode-16.2.0.app/Contents/Developer/Toolchains/
```

### Your Project Build Directory

```bash
~/Development/QRPayments/QRPaymentsCore/.build/
```

After building for Android:
```
.build/
├── aarch64-unknown-linux-android/    # Android ARM64 (cross-compiled from macOS)
│   └── release/
│       └── libQRPaymentsCore.so
└── arm64-apple-macosx/               # macOS native
    └── release/
```

## Build Commands (On Your Mac)

### Building for iOS (Native)

```bash
# In Xcode
# Just click Build & Run → Runs on iOS Simulator or Device

# Command line
cd QRPaymentsCore
swift build -c release
# Builds for macOS by default (your current platform)
```

### Building for Android (Cross-Compile)

```bash
# On your Mac, cross-compiling for Android
cd QRPaymentsCore
swift build --swift-sdk swift-6.2-RELEASE-android-24-0.1 -c release

# This produces: .build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so
# Even though you're on macOS!
```

## Common Confusion Clarified

### ❌ Wrong Thinking

"I'm on macOS, so I can't use `.linux` platform"

### ✅ Correct Understanding

- **macOS** = Your development machine
- **Linux** = Android's kernel (target platform)
- `.linux` in Swift = Target platform, NOT your development machine
- You build ON macOS, FOR Android (Linux-based)

### Example in Package.swift

```swift
.define("ANDROID", .when(platforms: [.linux]))
```

This means:
- ✅ "When building FOR Linux (Android), define ANDROID flag"
- ❌ NOT "Only works if you're ON Linux"

## Directory Structure (All on macOS)

```
~/Development/QRPayments/           # Your project (on macOS)
├── QRPaymentsCore/                 # Swift package (runs on macOS)
│   ├── Sources/                    # Swift code (edited on macOS)
│   ├── Package.swift               # Package manifest (on macOS)
│   └── .build/                     # Build outputs
│       ├── aarch64-unknown-linux-android/  # For Android devices
│       └── arm64-apple-macosx/     # For macOS/iOS
├── QRPaymentsIOS/                  # iOS app (Xcode on macOS)
└── QRPaymentsAndroid/              # Android app (Android Studio on macOS)
```

## Tools Required (All macOS)

| Tool | Purpose | Platform |
|------|---------|----------|
| **Xcode** | iOS development | macOS |
| **Swift toolchain** | Compile Swift code | macOS |
| **Swift SDK for Android** | Cross-compile for Android | macOS |
| **Android Studio** | Android development | macOS |
| **Android NDK** | Native Android libs | macOS |

## What You DON'T Need

- ❌ Linux machine
- ❌ Virtual machine running Linux
- ❌ Docker with Linux
- ❌ WSL (Windows Subsystem for Linux)

You do everything on macOS!

## Integration Workflow (macOS)

1. **Write Swift code** (on macOS, in Xcode or any editor)
2. **Build for iOS** (on macOS, using Xcode)
3. **Build for Android** (on macOS, cross-compile using Swift SDK)
4. **Copy .so to Android project** (on macOS)
5. **Build Android app** (on macOS, using Android Studio)
6. **Test on devices** (iOS device + Android device)

All steps happen on your Mac!

## Verification (All Commands on macOS)

```bash
# Check your macOS Swift version
swift --version
# Shows: Swift version 6.x (arm64-apple-macosx)

# Check installed SDKs
swift sdk list
# Shows: swift-6.2-RELEASE-android-24-0.1 (installed on macOS)

# Check SDK location (macOS path)
ls -la ~/Library/org.swift.swiftpm/swift-sdks/

# Build for Android (from macOS)
cd ~/Development/QRPayments/QRPaymentsCore
swift build --swift-sdk swift-6.2-RELEASE-android-24-0.1 -c release

# Check output (macOS path)
file .build/aarch64-unknown-linux-android/release/libQRPaymentsCore.so
# Shows: ELF 64-bit LSB shared object, ARM aarch64 (for Android!)
```

## Summary

- 🖥️ **Your Mac**: Development environment (macOS)
- 📱 **iOS**: Native target (same OS family as macOS)
- 🤖 **Android**: Cross-compile target (Linux-based OS)
- 📦 **Swift SDK for Android**: Cross-compilation toolchain (runs on macOS)
- 🔨 **All builds happen**: On your Mac

You're creating a **true multiplatform** Swift project, all from the comfort of macOS! 🚀

## Questions?

**Q: Why does the error mention Linux paths?**
A: Swift SDK for Android contains Linux system libraries for the target Android device. Your Mac uses these to cross-compile.

**Q: Do I need to know Linux?**
A: No! You're just building FOR Linux (Android), not developing ON Linux.

**Q: Will my code run on macOS?**
A: Yes! The same Swift code runs on iOS, macOS, and Android. That's the power of multiplatform!

**Q: Why `.when(platforms: [.linux])`?**
A: This activates code specifically for the Android (Linux) target when cross-compiling from macOS.
