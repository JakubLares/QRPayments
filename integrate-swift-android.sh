#!/bin/bash

# Swift-Android Integration Script
# This script builds the Swift library for Android and sets up JNI bindings

set -e  # Exit on error

echo "🚀 QR Payments - Swift Android Integration"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
SWIFT_PACKAGE="$PROJECT_ROOT/QRPaymentsCore"
ANDROID_PROJECT="$PROJECT_ROOT/QRPaymentsAndroid"
JNI_LIBS="$ANDROID_PROJECT/app/src/main/jniLibs/arm64-v8a"
GENERATED_BINDINGS="$ANDROID_PROJECT/app/src/main/java/com/qrpayments/bridge/generated"

# Step 1: Check Swift SDK for Android
echo "📦 Step 1: Checking Swift SDK for Android..."
if ! swift --version &> /dev/null; then
    echo -e "${RED}❌ Swift not found. Please install Swift first.${NC}"
    echo "   Download from: https://www.swift.org/install/"
    exit 1
fi

echo -e "${GREEN}✓ Swift found:${NC}"
swift --version
echo ""

# Check for Android Swift SDK
echo "Checking for Swift SDK for Android..."
if ! swift sdk list | grep -q "android"; then
    echo -e "${YELLOW}⚠️  Swift SDK for Android not found.${NC}"
    echo ""
    echo "To install Swift SDK for Android:"
    echo "1. Download from: https://www.swift.org/install/"
    echo "2. Or follow: https://github.com/swiftlang/swift-android-examples"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ Swift SDK for Android found${NC}"
fi
echo ""

# Step 2: Build Swift library for Android
echo "🔨 Step 2: Building Swift library for Android..."
cd "$SWIFT_PACKAGE"

echo "Building for Android ARM64..."
if swift build --swift-sdk aarch64-unknown-linux-android -c release --product QRPaymentsCore; then
    echo -e "${GREEN}✓ Swift library built successfully${NC}"

    # Find the .so file
    SO_FILE=$(find .build -name "libQRPaymentsCore.so" | grep "aarch64.*release")
    if [ -n "$SO_FILE" ]; then
        echo -e "${GREEN}✓ Found library: $SO_FILE${NC}"
    else
        echo -e "${RED}❌ Could not find libQRPaymentsCore.so${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Failed to build Swift library${NC}"
    echo ""
    echo "Possible reasons:"
    echo "1. Swift SDK for Android not properly installed"
    echo "2. Missing toolchain components"
    echo ""
    echo "Please follow: https://www.swift.org/blog/nightly-swift-sdk-for-android/"
    exit 1
fi
echo ""

# Step 3: Check for swift-java
echo "🔧 Step 3: Checking swift-java tooling..."
if ! command -v swift-java &> /dev/null; then
    echo -e "${YELLOW}⚠️  swift-java not found.${NC}"
    echo ""
    echo "To install swift-java:"
    echo "1. git clone https://github.com/swiftlang/swift-java"
    echo "2. cd swift-java"
    echo "3. swift build -c release"
    echo "4. Add to PATH or use full path"
    echo ""
    read -p "Do you have swift-java installed? Enter path (or 'skip' to skip): " SWIFT_JAVA_PATH

    if [ "$SWIFT_JAVA_PATH" = "skip" ]; then
        echo -e "${YELLOW}⚠️  Skipping JNI binding generation${NC}"
        echo "You'll need to generate bindings manually later."
    else
        SWIFT_JAVA_CMD="$SWIFT_JAVA_PATH"
    fi
else
    SWIFT_JAVA_CMD="swift-java"
    echo -e "${GREEN}✓ swift-java found${NC}"
fi
echo ""

# Step 4: Generate JNI bindings
if [ -n "$SWIFT_JAVA_CMD" ]; then
    echo "📝 Step 4: Generating JNI bindings..."

    mkdir -p "$GENERATED_BINDINGS"

    if $SWIFT_JAVA_CMD \
        --module QRPaymentsCore \
        --output "$GENERATED_BINDINGS" \
        --swift-sdk aarch64-unknown-linux-android; then
        echo -e "${GREEN}✓ JNI bindings generated${NC}"
        echo "Generated files in: $GENERATED_BINDINGS"
    else
        echo -e "${RED}❌ Failed to generate JNI bindings${NC}"
        echo "You may need to generate them manually."
    fi
    echo ""
fi

# Step 5: Copy .so file to Android project
echo "📦 Step 5: Copying Swift library to Android project..."
mkdir -p "$JNI_LIBS"

if [ -n "$SO_FILE" ]; then
    cp "$SO_FILE" "$JNI_LIBS/libQRPaymentsCore.so"
    echo -e "${GREEN}✓ Library copied to: $JNI_LIBS/libQRPaymentsCore.so${NC}"

    # Show file info
    ls -lh "$JNI_LIBS/libQRPaymentsCore.so"
else
    echo -e "${RED}❌ No library file to copy${NC}"
fi
echo ""

# Step 6: Update Android configuration
echo "⚙️  Step 6: Android project configuration..."
echo "The following updates are needed in build.gradle.kts:"
echo ""
echo "android {"
echo "    defaultConfig {"
echo "        ndk {"
echo "            abiFilters += listOf(\"arm64-v8a\")"
echo "        }"
echo "    }"
echo "}"
echo ""

# Summary
echo "=========================================="
echo "✅ Integration Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update SwiftBridge.kt to use generated bindings"
echo "2. Update build.gradle.kts with NDK configuration"
echo "3. Sync Gradle and rebuild in Android Studio"
echo "4. Test the app!"
echo ""
echo "See SWIFT_INTEGRATION_GUIDE.md for detailed instructions."
