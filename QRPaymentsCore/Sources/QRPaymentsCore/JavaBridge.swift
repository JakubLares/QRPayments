//
//  JavaBridge.swift
//  QRPaymentsCore
//
//  Java/Android bridge using swift-java's JNI interop
//  Exports Swift functions to be callable from Java/Kotlin via JNI
//

import Foundation
import SwiftJava
import JavaTypes

/// Java-friendly bridge for SPAYD generation
/// Exports Swift functions via JNI for calling from Java/Kotlin
public class SPAYDGeneratorSwift {

    /// Generates SPAYD format string for Czech QR payment
    /// - Parameters:
    ///   - prefix: Account prefix (can be empty)
    ///   - accountNumber: Main account number
    ///   - bankCode: Bank code (4 digits)
    ///   - amount: Payment amount (optional)
    ///   - variableSymbol: Variable symbol (optional)
    ///   - message: Message for receiver (optional)
    /// - Returns: SPAYD formatted string
    public static func generateSPAYD(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ) -> String {
        return SPAYDGenerator.generate(
            prefix: prefix,
            accountNumber: accountNumber,
            bankCode: bankCode,
            amount: amount,
            variableSymbol: variableSymbol,
            message: message
        )
    }

    /// Converts Czech account format to IBAN
    /// - Parameters:
    ///   - prefix: Account prefix (can be empty)
    ///   - accountNumber: Main account number
    ///   - bankCode: Bank code (4 digits)
    /// - Returns: IBAN string (e.g., CZ6508000000192000145399)
    public static func convertToIBAN(
        prefix: String,
        accountNumber: String,
        bankCode: String
    ) -> String {
        return SPAYDGenerator.convertToIBAN(
            prefix: prefix,
            accountNumber: accountNumber,
            bankCode: bankCode
        )
    }
}
