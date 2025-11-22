#!/bin/bash

# Simplified Swift-Android Build Script
# This script builds the Swift library for Android ARM64
# Requires: swiftly with Swift 6.2+ and Swift Android SDK installed

set -e

echo "🚀 Building Swift library for Android ARM64..."
echo ""

# Navigate to Swift package
cd "$(dirname "$0")/QRPaymentsCore"

# Clean previous build artifacts to ensure fresh build
if [ -d ".build" ]; then
    echo "🧹 Cleaning previous build artifacts..."
    rm -rf .build
fi

# Clean old runtime libraries from jniLibs (we're switching to static linking)
JNI_LIBS_TEMP="../QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a"
if [ -d "$JNI_LIBS_TEMP" ]; then
    echo "🧹 Cleaning old runtime libraries..."
    # Keep only our custom libraries, remove all runtime libs
    find "$JNI_LIBS_TEMP" -name "*.so" ! -name "libQRPaymentsCore.so" ! -name "libqrpaymentsbridge.so" -delete 2>/dev/null || true
fi

# Build using swiftly
echo "📦 Building with Swift 6.2 Android SDK..."

# Detect the installed Android SDK
ANDROID_SDK=$(swiftly run swift sdk list | grep -i "android" | head -1 | awk '{print $1}')

if [ -z "$ANDROID_SDK" ]; then
    echo "❌ Error: Swift Android SDK not found!"
    echo ""
    echo "Available SDKs:"
    swiftly run swift sdk list
    echo ""
    echo "Please install Swift Android SDK 6.2:"
    echo "Download from: https://github.com/finagolfin/swift-android-sdk/releases"
    exit 1
fi

echo "Using Android SDK: $ANDROID_SDK"
echo ""

# Build for ARM64 (64-bit) explicitly with STATIC stdlib linking
# Following official Swift Android examples pattern:
# - Use -static-stdlib to embed Swift runtime in the .so file
# - Specify resource directory for static Swift resources
# - This eliminates need for copying 40+ runtime libraries

# First, find the SDK path for resource directory
SDK_LIST_OUTPUT_EARLY=$(swiftly run swift sdk list 2>&1 | grep "$ANDROID_SDK" | grep " at " | head -1)
if [ -n "$SDK_LIST_OUTPUT_EARLY" ]; then
    SDK_PATH_EARLY=$(echo "$SDK_LIST_OUTPUT_EARLY" | sed -n 's/.*at \(.*\)/\1/p')
else
    SDK_PATH_EARLY="$HOME/Library/org.swift.swiftpm/swift-sdks/$ANDROID_SDK.artifactbundle/swift-6.2-release-android-24-sdk"
fi

RESOURCE_DIR="$SDK_PATH_EARLY/android-27d-sysroot/usr/lib/swift_static-aarch64"

swiftly run swift build \
    --swift-sdk "$ANDROID_SDK" \
    --triple aarch64-unknown-linux-android29 \
    -Xswiftc -static-stdlib \
    -Xswiftc -resource-dir \
    -Xswiftc "$RESOURCE_DIR" \
    -c debug \
    --product QRPaymentsCore

# Find the built library (ARM64 variant)
SO_FILE=$(find .build -name "libQRPaymentsCore.so" -type f | grep -E "aarch64|arm64" | head -1)

# Fallback to any .so if ARM64 not found
if [ -z "$SO_FILE" ]; then
    SO_FILE=$(find .build -name "libQRPaymentsCore.so" -type f | head -1)
fi

if [ -z "$SO_FILE" ]; then
    echo "❌ Error: libQRPaymentsCore.so not found in build output"
    echo ""
    echo "Build directory contents:"
    find .build -name "*.so" -type f 2>/dev/null || echo "No .so files found"
    exit 1
fi

echo "✅ Found library: $SO_FILE"
ls -lh "$SO_FILE"
echo ""

# Copy to Android project
JNI_LIBS="../QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a"
mkdir -p "$JNI_LIBS"

echo "📦 Copying Swift library to Android project..."
cp "$SO_FILE" "$JNI_LIBS/libQRPaymentsCore.so"
echo "✅ Library copied to: $JNI_LIBS/libQRPaymentsCore.so"
ls -lh "$JNI_LIBS/libQRPaymentsCore.so"
echo ""

# Copy C++ runtime library (ONLY library needed with static stdlib)
# Following official Swift Android examples pattern - they use -static-stdlib
# which embeds Swift runtime into the .so, so we only need libc++_shared.so
echo "📦 Copying C++ runtime library..."
echo ""

# Find SDK path for NDK sysroot
SDK_LIST_OUTPUT=$(swiftly run swift sdk list 2>&1 | grep "$ANDROID_SDK" | grep " at " | head -1)

if [ -n "$SDK_LIST_OUTPUT" ]; then
    SDK_PATH=$(echo "$SDK_LIST_OUTPUT" | sed -n 's/.*at \(.*\)/\1/p')
else
    SDK_PATH="$HOME/Library/org.swift.swiftpm/swift-sdks/$ANDROID_SDK.artifactbundle/swift-6.2-release-android-24-sdk"
fi

echo "📂 SDK Path: $SDK_PATH"

# Look for libc++_shared.so in NDK sysroot
NDK_LIB_PATH="$SDK_PATH/android-27d-sysroot/usr/lib/aarch64-linux-android/libc++_shared.so"

if [ -f "$NDK_LIB_PATH" ]; then
    echo "✅ Found libc++_shared.so in NDK sysroot"
    cp "$NDK_LIB_PATH" "$JNI_LIBS/libc++_shared.so"
    echo "✅ Copied libc++_shared.so"
    ls -lh "$JNI_LIBS/libc++_shared.so"
else
    echo "⚠️  Warning: libc++_shared.so not found at: $NDK_LIB_PATH"
    echo ""
    echo "Searching for libc++_shared.so in SDK..."
    CPP_LIB=$(find "$SDK_PATH" -name "libc++_shared.so" -type f | grep aarch64 | head -1)
    if [ -n "$CPP_LIB" ]; then
        echo "✅ Found at: $CPP_LIB"
        cp "$CPP_LIB" "$JNI_LIBS/libc++_shared.so"
        echo "✅ Copied libc++_shared.so"
        ls -lh "$JNI_LIBS/libc++_shared.so"
    else
        echo "❌ Error: libc++_shared.so not found in SDK!"
        exit 1
    fi
fi
echo ""

echo "=========================================="
echo "✅ Build Complete!"
echo "=========================================="
echo ""
echo "Built with STATIC stdlib linking (like official Swift Android examples)"
echo "This embeds Swift runtime into libQRPaymentsCore.so"
echo "Only libc++_shared.so is needed as external dependency"
echo ""
echo "Next steps:"
echo "1. Open Android Studio"
echo "2. Click Build → Rebuild Project"
echo "3. CMake will build the JNI bridge (libqrpaymentsbridge.so)"
echo "4. Run the app and check logcat for Swift initialization"
echo ""
