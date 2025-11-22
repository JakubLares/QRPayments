//
//  JavaBridge.swift
//  QRPaymentsCore
//
//  Java/Android bridge using swift-java's @JavaExport macro
//  This automatically generates JNI bindings for calling from Java/Kotlin
//

import Foundation
import JavaKit

/// Java-friendly bridge for SPAYD generation
/// Uses @JavaExport to automatically generate JNI wrappers
@JavaClass("com.qrpayments.core.SPAYDGeneratorSwift")
public class SPAYDGeneratorSwift {

    /// Generates SPAYD format string for Czech QR payment
    /// @param prefix Account prefix (can be empty)
    /// @param accountNumber Main account number
    /// @param bankCode Bank code (4 digits)
    /// @param amount Payment amount (can be null)
    /// @param variableSymbol Variable symbol (can be null)
    /// @param message Message for receiver (can be null)
    /// @return SPAYD formatted string
    @JavaMethod
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
    /// @param prefix Account prefix (can be empty)
    /// @param accountNumber Main account number
    /// @param bankCode Bank code (4 digits)
    /// @return IBAN string (e.g., CZ6508000000192000145399)
    @JavaMethod
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
