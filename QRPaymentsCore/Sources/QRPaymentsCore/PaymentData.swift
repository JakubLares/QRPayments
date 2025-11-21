//
//  PaymentData.swift
//  QRPaymentsCore
//
//  Payment data structure for QR code generation
//

import Foundation

/// Payment information for generating QR codes
public struct PaymentData: Codable, Hashable {
    public var account: BankAccount
    public var amount: String?
    public var variableSymbol: String?
    public var message: String?

    public init(
        account: BankAccount,
        amount: String? = nil,
        variableSymbol: String? = nil,
        message: String? = nil
    ) {
        self.account = account
        self.amount = amount
        self.variableSymbol = variableSymbol
        self.message = message
    }

    /// Generate SPAYD string for this payment
    public func generateSPAYD() -> String {
        return SPAYDGenerator.generate(
            prefix: account.prefix,
            accountNumber: account.accountNumber,
            bankCode: account.bankCode,
            amount: amount,
            variableSymbol: variableSymbol,
            message: message
        )
    }
}
