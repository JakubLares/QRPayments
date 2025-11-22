//
//  JavaBridge.swift
//  QRPaymentsCore
//
//  Java/Android bridge using @_cdecl for JNI export
//  These functions will be extracted by swift-java jextract tool
//

import Foundation

// MARK: - C-Compatible JNI Exports

/// Generates SPAYD format string for Czech QR payment
/// Exported as C function for JNI access from Java/Kotlin
@_cdecl("Swift_QRPaymentsCore_generateSPAYD")
public func Swift_QRPaymentsCore_generateSPAYD(
    prefix: UnsafePointer<CChar>,
    accountNumber: UnsafePointer<CChar>,
    bankCode: UnsafePointer<CChar>,
    amount: UnsafePointer<CChar>?,
    variableSymbol: UnsafePointer<CChar>?,
    message: UnsafePointer<CChar>?
) -> UnsafePointer<CChar> {
    let prefixStr = String(cString: prefix)
    let accountNumberStr = String(cString: accountNumber)
    let bankCodeStr = String(cString: bankCode)

    let amountStr: String? = amount.map { String(cString: $0) }
    let variableSymbolStr: String? = variableSymbol.map { String(cString: $0) }
    let messageStr: String? = message.map { String(cString: $0) }

    let result = SPAYDGenerator.generate(
        prefix: prefixStr,
        accountNumber: accountNumberStr,
        bankCode: bankCodeStr,
        amount: amountStr,
        variableSymbol: variableSymbolStr,
        message: messageStr
    )

    // Convert result to C string and return
    // Note: The caller must free this memory
    return strdup(result)
}

/// Converts Czech account format to IBAN
/// Exported as C function for JNI access from Java/Kotlin
@_cdecl("Swift_QRPaymentsCore_convertToIBAN")
public func Swift_QRPaymentsCore_convertToIBAN(
    prefix: UnsafePointer<CChar>,
    accountNumber: UnsafePointer<CChar>,
    bankCode: UnsafePointer<CChar>
) -> UnsafePointer<CChar> {
    let prefixStr = String(cString: prefix)
    let accountNumberStr = String(cString: accountNumber)
    let bankCodeStr = String(cString: bankCode)

    let result = SPAYDGenerator.convertToIBAN(
        prefix: prefixStr,
        accountNumber: accountNumberStr,
        bankCode: bankCodeStr
    )

    // Convert result to C string and return
    // Note: The caller must free this memory
    return strdup(result)
}

// MARK: - Swift-Friendly Wrapper (for jextract)

/// Swift class wrapper for SPAYD generation
/// The jextract tool will generate Java bindings from this class
public class SPAYDGeneratorBridge {

    /// Generates SPAYD format string for Czech QR payment
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
