//
//  Validator.swift
//  QRPaymentsCore
//
//  Validation utilities for bank account data
//

import Foundation

public struct Validator {

    /// Validates Czech bank code (must be 4 digits)
    public static func isValidBankCode(_ code: String) -> Bool {
        return code.count == 4 && code.allSatisfy { $0.isNumber }
    }

    /// Validates account number (numeric, up to 10 digits)
    public static func isValidAccountNumber(_ number: String) -> Bool {
        return !number.isEmpty && number.count <= 10 && number.allSatisfy { $0.isNumber }
    }

    /// Validates account prefix (optional, numeric, up to 6 digits)
    public static func isValidPrefix(_ prefix: String) -> Bool {
        if prefix.isEmpty {
            return true
        }
        return prefix.count <= 6 && prefix.allSatisfy { $0.isNumber }
    }

    /// Validates variable symbol (optional, numeric, up to 10 digits)
    public static func isValidVariableSymbol(_ symbol: String) -> Bool {
        if symbol.isEmpty {
            return true
        }
        return symbol.count <= 10 && symbol.allSatisfy { $0.isNumber }
    }

    /// Validates amount (optional, positive number)
    public static func isValidAmount(_ amount: String) -> Bool {
        if amount.isEmpty {
            return true
        }
        guard let value = Double(amount) else {
            return false
        }
        return value > 0
    }

    /// Validates complete bank account
    public static func validateAccount(
        name: String,
        prefix: String,
        accountNumber: String,
        bankCode: String
    ) -> (isValid: Bool, error: String?) {
        if name.isEmpty {
            return (false, "Account name is required")
        }

        if !isValidPrefix(prefix) {
            return (false, "Invalid prefix format")
        }

        if !isValidAccountNumber(accountNumber) {
            return (false, "Invalid account number")
        }

        if !isValidBankCode(bankCode) {
            return (false, "Bank code must be exactly 4 digits")
        }

        return (true, nil)
    }
}
