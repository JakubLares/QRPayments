#!/bin/bash

# Simplified Swift-Android Build Script
# This script builds the Swift library for Android ARM64
# Requires: swiftly with Swift 6.2+ and Swift Android SDK installed

set -e

echo "🚀 Building Swift library for Android ARM64..."
echo ""

# Navigate to Swift package
cd "$(dirname "$0")/QRPaymentsCore"

# Build using swiftly
echo "📦 Building with Swift 6.2 Android SDK..."
swiftly run swift build \
    -c debug \
    --triple aarch64-unknown-linux-android28 \
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
