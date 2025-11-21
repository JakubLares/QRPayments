# QR Pay - Czech Banking QR Payment App

A modern iOS mobile application for storing bank accounts and generating QR codes for payments using the Czech SPAYD (Short Payment Descriptor) standard.

## Features

- ✅ **Account Management**: Store and manage multiple Czech bank accounts
- ✅ **QR Code Generation**: Generate SPAYD-format QR codes for instant payments
- ✅ **Modern iOS 26 Design**: Beautiful Liquid Glass design language
- ✅ **SwiftData Persistence**: Securely store accounts locally on device
- ✅ **Czech Banking Standard**: Full support for Czech account format (prefix-accountNumber/bankCode)

## Screenshots

The app includes three main screens:
1. **Accounts List** - View all saved bank accounts with a card-style interface
2. **New Account** - Add new bank accounts with Czech format validation
3. **QR Generation** - Create payment QR codes with amount, variable symbol, and message

## Technical Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Persistence**: SwiftData
- **Minimum iOS**: iOS 16.0+
- **Design**: iOS 26 Liquid Glass design language
- **QR Standard**: SPAYD (Short Payment Descriptor) for Czech banking

## SPAYD Format

The app generates QR codes in the SPAYD format, which is the standard for Czech QR payments:

```
SPD*1.0*ACC:CZ6508000000192000145399*AM:900.00*CC:CZK*MSG:Payment*X-VS:1234567890
```

Components:
- `SPD*1.0` - SPAYD version
- `ACC` - Account IBAN
- `AM` - Amount (optional)
- `CC` - Currency (CZK)
- `MSG` - Message for receiver (optional)
- `X-VS` - Variable Symbol (optional)

## Czech Account Format

The app supports the standard Czech bank account format:

```
[prefix]-accountNumber/bankCode
```

Examples:
- `19-2121134949/6100` (with prefix)
- `1234567890/0100` (without prefix)

Where:
- **Prefix**: 0-6 digits (optional)
- **Account Number**: Up to 10 digits (required)
- **Bank Code**: 4 digits (required)

## Project Structure

```
QRPayments/
├── App/
│   └── QRPaymentsApp.swift          # Main app entry point
├── Models/
│   └── BankAccount.swift            # SwiftData model for accounts
├── Views/
│   ├── AccountsListView.swift       # List of all accounts
│   ├── NewAccountView.swift         # Add new account form
│   └── QRGenerationView.swift       # QR code generation screen
├── Utilities/
│   ├── SPAYDGenerator.swift         # SPAYD format generator
│   └── QRCodeGenerator.swift        # QR code image generator
└── Resources/
    └── Info.plist                   # App configuration
```

## How to Build

### Requirements

- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- macOS Ventura 13.0 or later

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/JakubLares/QRPayments.git
   cd QRPayments
   ```

2. Open the project in Xcode:
   ```bash
   open QRPayments.xcodeproj
   ```

3. Select your target device/simulator

4. Build and run (⌘R)

## Usage

### Adding a New Account

1. Tap the "Press to create new Account card" button
2. Fill in the account details:
   - Account Name (e.g., "Equa Bank - Family Account")
   - Prefix (optional, e.g., "19")
   - Account Number (required, e.g., "2121134949")
   - Bank Code (required, 4 digits, e.g., "6100")
3. Tap "Add Account"

### Generating a QR Code

1. Tap on any account from the list
2. Enter payment details:
   - Amount (e.g., "900")
   - Variable Symbol (optional)
   - Message for receiver (optional)
3. Tap "Generate QR Code"
4. Scan the QR code with your mobile banking app

## Future Enhancements

- [ ] Bank logo database integration
- [ ] Multiple currency support
- [ ] Payment history
- [ ] QR code sharing functionality
- [ ] Dark mode support
- [ ] Face ID / Touch ID security
- [ ] Export/Import accounts
- [ ] Widget support

## Banking Compatibility

This app generates standard SPAYD QR codes that are compatible with all major Czech banks:

- Česká spořitelna
- Komerční banka
- ČSOB
- Raiffeisenbank
- mBank
- Equa bank
- Air Bank
- Fio banka
- And more...

## License

MIT License - See LICENSE file for details

## Author

Created with ❤️ for Czech banking users

## Support

For issues or questions, please open an issue on GitHub.
