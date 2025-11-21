# QR Payments Android

Android version of the QR Payments app built with Jetpack Compose.

## Requirements

- Android Studio Hedgehog (2023.1.1) or later
- JDK 17 or later
- Android SDK with API level 26 (Android 8.0) minimum
- Android device or emulator running Android 8.0+

## Building the App

### Option 1: Using Android Studio (Recommended)

1. **Install Android Studio**
   - Download from: https://developer.android.com/studio
   - Install with default settings

2. **Open the Project**
   - Launch Android Studio
   - Click "Open" or "File → Open"
   - Navigate to and select the `QRPaymentsAndroid` folder
   - Wait for Gradle sync to complete (first time may take several minutes)

3. **Run the App**
   - Connect an Android device or start an emulator
   - Click the "Run" button (▶) or press Shift+F10
   - Select your device/emulator
   - The app will build and install automatically

### Option 2: Using Command Line

If you have Android SDK installed:

```bash
cd QRPaymentsAndroid

# On macOS/Linux:
chmod +x gradlew
./gradlew build
./gradlew installDebug

# On Windows:
gradlew.bat build
gradlew.bat installDebug
```

## Project Structure

```
QRPaymentsAndroid/
├── app/
│   ├── src/main/
│   │   ├── java/com/qrpayments/
│   │   │   ├── MainActivity.kt          # Entry point
│   │   │   ├── bridge/                  # Swift-Kotlin bridge
│   │   │   │   └── SwiftBridge.kt       # Business logic interface
│   │   │   ├── data/                    # Data layer
│   │   │   │   ├── BankAccount.kt       # Account model
│   │   │   │   ├── PaymentData.kt       # Payment model
│   │   │   │   └── AccountsRepository.kt # DataStore repository
│   │   │   ├── ui/                      # UI layer
│   │   │   │   ├── QRPaymentsApp.kt     # Navigation
│   │   │   │   ├── AccountsViewModel.kt # ViewModel
│   │   │   │   ├── theme/               # Material 3 theme
│   │   │   │   └── screens/             # Compose screens
│   │   │   └── util/                    # Utilities
│   │   │       └── QRCodeGenerator.kt   # QR generation (ZXing)
│   │   └── res/                         # Resources
│   │       └── values/
│   │           ├── strings.xml          # Localized strings
│   │           └── themes.xml           # Theme definition
│   └── build.gradle.kts                 # App build config
├── build.gradle.kts                     # Root build config
├── settings.gradle.kts                  # Project settings
└── gradle.properties                    # Gradle properties
```

## Features

- ✅ Account management (add, edit, delete)
- ✅ QR code generation with SPAYD format
- ✅ Local data persistence with DataStore
- ✅ Material 3 design
- ✅ Full feature parity with iOS version

## Troubleshooting

### Gradle Sync Issues

If Gradle sync fails:
1. File → Invalidate Caches → Invalidate and Restart
2. Delete `.gradle` folder in project root
3. Sync again: File → Sync Project with Gradle Files

### SDK/NDK Issues

If you see SDK-related errors:
1. File → Project Structure → SDK Location
2. Ensure Android SDK path is set correctly
3. Install required SDK components via SDK Manager

### Build Errors

If you see "Could not resolve dependencies":
1. Check your internet connection
2. File → Settings → Build, Execution, Deployment → Build Tools → Gradle
3. Ensure "Gradle JDK" is set to JDK 17+

### Emulator Issues

If emulator won't start:
1. Tools → AVD Manager
2. Create new Virtual Device
3. Select any Pixel device
4. Choose system image: API 26+ (Oreo or higher)

## Testing on Physical Device

1. Enable Developer Options on your Android device:
   - Settings → About phone
   - Tap "Build number" 7 times

2. Enable USB Debugging:
   - Settings → Developer options
   - Toggle "USB debugging" ON

3. Connect device via USB
4. Allow USB debugging when prompted
5. Run the app from Android Studio

## Note About Swift Integration

The current implementation uses a **Kotlin bridge** (`SwiftBridge.kt`) that implements the Swift business logic in Kotlin. This allows you to:
- ✅ Build and run the app immediately
- ✅ Test all features
- ✅ No Swift SDK for Android required yet

To integrate the actual Swift code via swift-java, see: `../SWIFT_ANDROID_SETUP.md`

## Resources

- [Android Studio User Guide](https://developer.android.com/studio/intro)
- [Jetpack Compose Tutorial](https://developer.android.com/jetpack/compose/tutorial)
- [Material 3 Design](https://m3.material.io/)
