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

# Build for ARM64 (64-bit) with DYNAMIC linking
# NOTE: Static stdlib linking doesn't work for shared libraries (.so files) on Android
# It only works for executables. Since we're building libQRPaymentsCore.so for JNI,
# we MUST use dynamic linking and ship all Swift runtime libraries with the APK.
# Source: https://forums.swift.org/t/android-link-failures-with-static-swift-stdlib/61853
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

# Copy Swift runtime libraries (ALL libraries - dynamic linking required for .so files)
echo "📦 Copying Swift runtime libraries..."
echo ""

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
echo ""

# Find Swift runtime libraries in the SDK
# Copy ALL libraries from usr/lib/aarch64-linux-android (including FoundationICU)
# This is required for dynamic linking - we cannot use static linking for .so files
SWIFT_RUNTIME_LIBS=""

if [ -d "$SDK_PATH" ]; then
    echo "🔍 Searching for Swift runtime libraries..."

    # Find the aarch64-linux-android directory
    ARCH_LIB_DIR=$(find "$SDK_PATH" -type d -path "*/usr/lib/aarch64-linux-android" 2>/dev/null | head -1)

    if [ -n "$ARCH_LIB_DIR" ] && [ -d "$ARCH_LIB_DIR" ]; then
        echo "   ✅ Found arch lib directory: $ARCH_LIB_DIR"

        # Get ALL .so files (maxdepth 1 excludes 32/ subdirectory)
        # Include ALL libraries including FoundationICU for complete Swift runtime support
        SWIFT_RUNTIME_LIBS=$(find "$ARCH_LIB_DIR" -maxdepth 1 -type f -name "*.so" 2>/dev/null)
    else
        echo "   ⚠️  Could not find aarch64-linux-android directory, falling back to broader search..."
        SWIFT_RUNTIME_LIBS=$(find "$SDK_PATH" -type f -name "*.so" 2>/dev/null | grep -E "aarch64" | grep -v "/32/")
    fi

    if [ -n "$SWIFT_RUNTIME_LIBS" ]; then
        echo "   ✅ Found $(echo "$SWIFT_RUNTIME_LIBS" | wc -l | xargs) Swift runtime libraries"
        echo ""
    fi
fi

if [ -n "$SWIFT_RUNTIME_LIBS" ]; then
    echo "📦 Copying runtime libraries to jniLibs..."
    COPIED_COUNT=0
    for lib in $SWIFT_RUNTIME_LIBS; do
        lib_name=$(basename "$lib")
        cp "$lib" "$JNI_LIBS/$lib_name"
        COPIED_COUNT=$((COPIED_COUNT + 1))
    done
    echo "✅ Copied $COPIED_COUNT runtime libraries"
    echo ""
    echo "Libraries (showing first 20):"
    ls -lh "$JNI_LIBS"/*.so 2>/dev/null | grep -v "libQRPaymentsCore.so" | grep -v "libqrpaymentsbridge.so" | head -20 | awk '{print "  " $9 " (" $5 ")"}'
else
    echo "❌ Error: Runtime libraries not found in SDK!"
    echo "    Searched in: $SDK_PATH"
    exit 1
fi
echo ""

echo "=========================================="
echo "✅ Build Complete!"
echo "=========================================="
echo ""
echo "Built with DYNAMIC stdlib linking (required for .so files)"
echo "All Swift runtime libraries included (~40 libraries, ~95MB)"
echo ""
echo "⚠️  Note: Static linking doesn't work for shared libraries on Android"
echo "Source: https://forums.swift.org/t/android-link-failures-with-static-swift-stdlib/61853"
echo ""
echo "Next steps:"
echo "1. Open Android Studio"
echo "2. Click Build → Rebuild Project"
echo "3. CMake will build the JNI bridge (libqrpaymentsbridge.so)"
echo "4. Run the app and check logcat for Swift library loading"
echo ""
