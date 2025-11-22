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
echo ""

# finagolfin's SDK stores runtime libs in the SDK bundle, not build output
# Find the SDK installation directory
echo "🔍 Detecting SDK installation path..."
SDK_LIST_OUTPUT=$(swiftly run swift sdk list 2>&1 | grep "$ANDROID_SDK" | grep " at " | head -1)

if [ -n "$SDK_LIST_OUTPUT" ]; then
    echo "   Found SDK list entry: $SDK_LIST_OUTPUT"
    SDK_PATH=$(echo "$SDK_LIST_OUTPUT" | sed -n 's/.*at \(.*\)/\1/p')
    echo "   Extracted path: $SDK_PATH"
fi

if [ -z "$SDK_PATH" ]; then
    echo "⚠️  Could not determine SDK path from swiftly, trying default location..."
    SDK_PATH="$HOME/Library/org.swift.swiftpm/swift-sdks/$ANDROID_SDK.artifactbundle/swift-6.2-release-android-24-sdk"
fi

echo "📂 SDK Path: $SDK_PATH"

# Verify the directory exists
if [ ! -d "$SDK_PATH" ]; then
    echo "⚠️  SDK directory does not exist: $SDK_PATH"
    echo ""
    echo "Let's check what SDK directories are available:"
    echo ""
    if [ -d "$HOME/Library/org.swift.swiftpm/swift-sdks" ]; then
        ls -la "$HOME/Library/org.swift.swiftpm/swift-sdks/" 2>/dev/null || true
    else
        echo "   $HOME/Library/org.swift.swiftpm/swift-sdks directory not found"
    fi
    echo ""
fi
echo ""

# Find Swift runtime libraries in the SDK
SWIFT_RUNTIME_LIBS=""

# Try common locations in finagolfin's SDK structure
if [ -d "$SDK_PATH" ]; then
    echo "🔍 Searching for Swift runtime libraries in SDK..."
    echo ""

    # Show what directories are available for debugging
    echo "   Swift-related directories in SDK:"
    find "$SDK_PATH" -type d -name "*swift*" 2>/dev/null | grep -i "lib" | head -5
    echo ""

    # Search for Swift, dispatch, Blocks, and Foundation libraries
    # Exclude lib_FoundationICU.so (39MB) - too large and not needed for basic operations
    echo "   Searching for required runtime libraries (excluding FoundationICU)..."
    ALL_LIBS=$(find "$SDK_PATH" -type f \( \
        -name "libswift*.so" -o \
        -name "libdispatch.so" -o \
        -name "libBlocksRuntime.so" -o \
        -name "libFoundation.so" -o \
        -name "lib_*.so" \
        \) 2>/dev/null | grep -E "aarch64|arm64")

    # Filter out the huge ICU library but keep other Foundation libs
    SWIFT_RUNTIME_LIBS=$(echo "$ALL_LIBS" | grep -v "lib_FoundationICU.so")

    if [ -n "$SWIFT_RUNTIME_LIBS" ]; then
        echo "   ✅ Found $(echo "$SWIFT_RUNTIME_LIBS" | wc -l | xargs) Swift runtime libraries"
        echo ""
        echo "   Sample libraries found:"
        echo "$SWIFT_RUNTIME_LIBS" | head -5 | sed 's/^/     /'
    else
        echo "   ⚠️  No Swift libraries found!"
        echo ""
        echo "   Showing all .so files with aarch64/arm64 in path (first 20):"
        find "$SDK_PATH" -type f -name "*.so" 2>/dev/null | grep -E "aarch64|arm64" | head -20 | sed 's/^/     /'
    fi
    echo ""
fi

if [ -n "$SWIFT_RUNTIME_LIBS" ]; then
    COPIED_COUNT=0
    for lib in $SWIFT_RUNTIME_LIBS; do
        lib_name=$(basename "$lib")
        cp "$lib" "$JNI_LIBS/$lib_name"
        COPIED_COUNT=$((COPIED_COUNT + 1))
    done
    echo "✅ Copied $COPIED_COUNT runtime libraries from SDK"
    echo ""
    echo "Runtime libraries (showing first 25):"
    ls -lh "$JNI_LIBS"/*.so 2>/dev/null | grep -v "libQRPaymentsCore.so" | grep -v "libqrpaymentsbridge.so" | head -25 | awk '{print "  " $9 " (" $5 ")"}'
else
    echo "⚠️  Warning: Runtime libraries not found in SDK!"
    echo "    Searched in: $SDK_PATH"
    echo ""
    echo "    Please manually copy runtime libraries from:"
    echo "    $SDK_PATH/usr/lib/swift/android/"
    echo "    to: $JNI_LIBS/"
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
