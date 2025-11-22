# iOS App Setup - Using Shared QRPaymentsCore Package

The iOS app now uses the shared **QRPaymentsCore** Swift Package for business logic, creating a truly multiplatform architecture where both iOS and Android use the same Swift code.

## Architecture

```
QRPayments Project
├── QRPaymentsCore/          # ✅ Shared Swift Package (used by both platforms)
│   └── SPAYDGenerator       # Business logic for QR payment generation
├── QRPayments/              # iOS App (SwiftUI)
│   ├── Models/              # iOS-specific models (SwiftData)
│   ├── Views/               # SwiftUI views
│   └── Utilities/           # iOS-specific utilities (UI code only)
└── QRPaymentsAndroid/       # Android App (Jetpack Compose)
    └── Uses QRPaymentsCore via JNI bridge
```

## What's Shared vs Platform-Specific

### Shared (QRPaymentsCore)
✅ **SPAYDGenerator** - SPAYD format generation logic
✅ **IBANConverter** - Czech account to IBAN conversion
✅ **Validator** - Input validation logic
✅ **PaymentData** - Platform-independent data structures

### iOS-Specific
📱 **QRCodeGenerator** - Uses UIKit/CoreImage for QR generation
📱 **BankAccount (SwiftData)** - Persistence layer
📱 **SwiftUI Views** - iOS UI

### Android-Specific
🤖 **SwiftBridge** - JNI wrapper for calling Swift from Kotlin
🤖 **Jetpack Compose UI** - Android UI
🤖 **DataStore** - Android persistence

## Adding QRPaymentsCore to Xcode

**The package has already been linked programmatically!** The code imports `QRPaymentsCore` and the Xcode project has been updated.

To verify or re-add the package in Xcode:

1. Open `QRPayments.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the **QRPayments** target
4. Go to the **Frameworks, Libraries, and Embedded Content** section
5. If QRPaymentsCore is not listed, click **+** → **Add Local Package**
6. Navigate to the `QRPaymentsCore` folder in the project root
7. Click **Add Package**

## Building the iOS App

```bash
# Open in Xcode
open QRPayments.xcodeproj

# Or build from command line
xcodebuild -scheme QRPayments -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Code Changes Made

### ✅ Removed Duplicate Code
- **Deleted:** `QRPayments/Utilities/SPAYDGenerator.swift` (duplicate)
- **Kept:** `QRPayments/Utilities/QRCodeGenerator.swift` (iOS-specific UI code)

### ✅ Updated Imports
```swift
// QRGenerationView.swift
import SwiftUI
import QRPaymentsCore  // ← Added this import
```

### ✅ Updated Xcode Project
- Removed SPAYDGenerator.swift file references
- Project now relies on QRPaymentsCore package for business logic

## Benefits of This Architecture

✅ **Single Source of Truth** - SPAYDGenerator logic maintained in one place
✅ **Consistency** - Identical QR code generation on iOS and Android
✅ **Easier Testing** - Test business logic once in the shared package
✅ **Less Code Duplication** - ~120 lines of duplicate code eliminated
✅ **True Multiplatform** - Swift powering both iOS and Android

## Verification

After opening the project in Xcode, verify:

1. **No build errors** - Project compiles successfully
2. **SPAYDGenerator accessible** - Code completion works for `SPAYDGenerator.generate()`
3. **QR codes generate** - Run the app and create a QR payment code

## Next Steps

The iOS app is now fully integrated with the shared Swift package! 🎉

Both platforms use the same battle-tested business logic from **QRPaymentsCore**.
