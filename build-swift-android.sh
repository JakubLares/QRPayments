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

swiftly run swift build \
    --swift-sdk "$ANDROID_SDK" \
    -c debug \
    --product QRPaymentsCore

# Find the built library
SO_FILE=$(find .build -name "libQRPaymentsCore.so" | grep "aarch64.*debug" | head -1)

if [ -z "$SO_FILE" ]; then
    echo "❌ Error: libQRPaymentsCore.so not found in build output"
    exit 1
fi

echo "✅ Found library: $SO_FILE"
ls -lh "$SO_FILE"
echo ""

# Copy to Android project
JNI_LIBS="../QRPaymentsAndroid/app/src/main/jniLibs/arm64-v8a"
mkdir -p "$JNI_LIBS"

echo "📦 Copying to Android project..."
cp "$SO_FILE" "$JNI_LIBS/libQRPaymentsCore.so"

echo "✅ Library copied to: $JNI_LIBS/libQRPaymentsCore.so"
ls -lh "$JNI_LIBS/libQRPaymentsCore.so"
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
