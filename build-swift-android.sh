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

# Build for ARM64 (64-bit) explicitly
# finagolfin's SDK defaults to armv7 (32-bit), so we need to specify the triple
swiftly run swift build \
    --swift-sdk "$ANDROID_SDK" \
    --triple aarch64-unknown-linux-android29 \
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

# Copy Swift runtime libraries
echo "📦 Copying Swift runtime libraries..."
SWIFT_LIBS_DIR=$(dirname "$SO_FILE")

# Find and copy all Swift standard library dependencies
SWIFT_RUNTIME_LIBS=$(find "$SWIFT_LIBS_DIR" -name "libswift*.so" -type f)

if [ -z "$SWIFT_RUNTIME_LIBS" ]; then
    echo "⚠️  Warning: No Swift runtime libraries found in $SWIFT_LIBS_DIR"
    echo "    Checking parent directories..."
    SWIFT_RUNTIME_LIBS=$(find .build -name "libswift*.so" -type f | grep -E "aarch64|arm64" | head -20)
fi

if [ -n "$SWIFT_RUNTIME_LIBS" ]; then
    COPIED_COUNT=0
    for lib in $SWIFT_RUNTIME_LIBS; do
        lib_name=$(basename "$lib")
        cp "$lib" "$JNI_LIBS/$lib_name"
        COPIED_COUNT=$((COPIED_COUNT + 1))
    done
    echo "✅ Copied $COPIED_COUNT Swift runtime libraries"
    echo ""
    echo "Swift runtime libraries:"
    ls -lh "$JNI_LIBS"/libswift*.so | awk '{print "  " $9 " (" $5 ")"}'
else
    echo "⚠️  Warning: Swift runtime libraries not found!"
    echo "    The app may fail to load the Swift library at runtime."
fi
echo ""

echo "=========================================="
echo "✅ Build Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Open Android Studio"
echo "2. Click Build → Rebuild Project"
echo "3. CMake will build the JNI bridge (libqrpaymentsbridge.so)"
echo "4. Run the app and check logcat for '✅ JNI bridge loaded successfully!'"
echo ""
