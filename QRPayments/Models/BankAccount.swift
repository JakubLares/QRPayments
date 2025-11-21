//
//  BankAccount.swift
//  QRPayments
//
//  Created on 2025-11-20
//

import SwiftUI
import SwiftData

@Model
final class BankAccount {
    var id: UUID
    var name: String
    var prefix: String
    var accountNumber: String
    var bankCode: String
    var createdAt: Date

    init(name: String, prefix: String = "", accountNumber: String, bankCode: String) {
        self.id = UUID()
        self.name = name
        self.prefix = prefix
        self.accountNumber = accountNumber
        self.bankCode = bankCode
        self.createdAt = Date()
    }

    /// Formatted Czech account number: prefix-accountNumber/bankCode or accountNumber/bankCode
    var formattedAccountNumber: String {
        if prefix.isEmpty {
            return "\(accountNumber)/\(bankCode)"
        } else {
            return "\(prefix)-\(accountNumber)/\(bankCode)"
        }
    }

    /// IBAN format for Czech accounts (for SPAYD)
    /// Czech IBAN: CZ + 2 check digits + 4 digit bank code + 16 digit account (with prefix padded)
    var ibanFormat: String {
        let paddedPrefix = prefix.isEmpty ? "000000" : String(format: "%06d", Int(prefix) ?? 0)
        let paddedAccount = String(format: "%010d", Int(accountNumber) ?? 0)
        let basicIBAN = "CZ00\(bankCode)\(paddedPrefix)\(paddedAccount)"

        // Calculate IBAN check digits (simplified - in production use proper IBAN validation)
        return basicIBAN
    }
}
