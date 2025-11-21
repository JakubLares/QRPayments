//
//  BankAccount.swift
//  QRPaymentsCore
//
//  Platform-independent bank account model
//

import Foundation

/// Bank account model for Czech banking system
/// Pure Swift model without platform-specific dependencies
public struct BankAccount: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var prefix: String
    public var accountNumber: String
    public var bankCode: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        prefix: String = "",
        accountNumber: String,
        bankCode: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.prefix = prefix
        self.accountNumber = accountNumber
        self.bankCode = bankCode
        self.createdAt = createdAt
    }

    /// Formatted Czech account number: prefix-accountNumber/bankCode or accountNumber/bankCode
    public var formattedAccountNumber: String {
        if prefix.isEmpty {
            return "\(accountNumber)/\(bankCode)"
        } else {
            return "\(prefix)-\(accountNumber)/\(bankCode)"
        }
    }

    /// IBAN format for Czech accounts
    /// Czech IBAN: CZ + 2 check digits + 4 digit bank code + 16 digit account (with prefix padded)
    public var ibanFormat: String {
        return SPAYDGenerator.convertToIBAN(
            prefix: prefix,
            accountNumber: accountNumber,
            bankCode: bankCode
        )
    }
}
