//
//  SPAYDGenerator.swift
//  QRPaymentsCore
//
//  SPAYD (Short Payment Descriptor) generator for Czech QR payments
//  Format: SPD*1.0*ACC:IBAN*AM:amount*CC:CZK*MSG:message*X-VS:variableSymbol
//

import Foundation

public struct SPAYDGenerator {

    /// Generates SPAYD format string for Czech QR payment
    /// - Parameters:
    ///   - iban: Account IBAN (e.g., CZ6508000000192000145399)
    ///   - amount: Payment amount (optional)
    ///   - variableSymbol: Variable symbol (optional)
    ///   - message: Message for receiver (optional)
    /// - Returns: SPAYD formatted string
    public static func generate(
        iban: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ) -> String {
        var components = [String]()

        // Required: Version and Account
        components.append("SPD*1.0")
        components.append("ACC:\(iban)")

        // Optional: Amount
        if let amount = amount, !amount.isEmpty, let amountValue = Double(amount), amountValue > 0 {
            let formattedAmount = String(format: "%.2f", amountValue)
            components.append("AM:\(formattedAmount)")
        }

        // Required: Currency (always CZK for Czech payments)
        components.append("CC:CZK")

        // Optional: Message for receiver
        if let message = message, !message.isEmpty {
            let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? message
            components.append("MSG:\(encodedMessage)")
        }

        // Optional: Variable Symbol
        if let variableSymbol = variableSymbol, !variableSymbol.isEmpty {
            components.append("X-VS:\(variableSymbol)")
        }

        return components.joined(separator: "*")
    }

    /// Generates SPAYD string from Czech account format (prefix-accountNumber/bankCode)
    /// - Parameters:
    ///   - prefix: Account prefix (optional)
    ///   - accountNumber: Main account number
    ///   - bankCode: Bank code (4 digits)
    ///   - amount: Payment amount (optional)
    ///   - variableSymbol: Variable symbol (optional)
    ///   - message: Message for receiver (optional)
    /// - Returns: SPAYD formatted string
    public static func generate(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ) -> String {
        let iban = convertToIBAN(prefix: prefix, accountNumber: accountNumber, bankCode: bankCode)
        return generate(iban: iban, amount: amount, variableSymbol: variableSymbol, message: message)
    }

    /// Converts Czech account format to IBAN
    /// Czech IBAN format: CZ + 2 check digits + 4 digit bank code + 16 digit account (6 digit prefix + 10 digit account)
    public static func convertToIBAN(prefix: String, accountNumber: String, bankCode: String) -> String {
        // Pad prefix to 6 digits
        let paddedPrefix = prefix.isEmpty ? "000000" : String(format: "%06d", Int(prefix) ?? 0)

        // Pad account number to 10 digits
        let paddedAccount = String(format: "%010d", Int(accountNumber) ?? 0)

        // Combine bank code + prefix + account
        let bban = "\(bankCode)\(paddedPrefix)\(paddedAccount)"

        // Calculate IBAN check digits
        let checkDigits = calculateIBANCheckDigits(countryCode: "CZ", bban: bban)

        return "CZ\(checkDigits)\(bban)"
    }

    /// Calculates IBAN check digits using MOD 97 algorithm
    private static func calculateIBANCheckDigits(countryCode: String, bban: String) -> String {
        // Move country code and 00 to the end
        let rearranged = bban + countryCode + "00"

        // Replace letters with numbers (A=10, B=11, ..., Z=35)
        var numericString = ""
        for char in rearranged {
            if char.isLetter {
                let value = Int(char.asciiValue! - 65 + 10)
                numericString += String(value)
            } else {
                numericString += String(char)
            }
        }

        // Calculate MOD 97
        var remainder = 0
        for char in numericString {
            remainder = (remainder * 10 + Int(String(char))!) % 97
        }

        let checkDigit = 98 - remainder
        return String(format: "%02d", checkDigit)
    }
}
