package com.qrpayments.bridge

import com.qrpayments.data.BankAccount

/**
 * Bridge to Swift QRPaymentsCore library via JNI
 * Calls native Swift functions exported with @_cdecl
 */
object SwiftBridge {

    private const val TAG = "SwiftBridge"

    init {
        // IMPORTANT: Load Swift library FIRST, then JNI bridge
        // The JNI bridge depends on Swift library, so order matters
        android.util.Log.d(TAG, "Loading Swift library...")
        System.loadLibrary("QRPaymentsCore")
        android.util.Log.d(TAG, "✅ Swift library loaded successfully!")

        android.util.Log.d(TAG, "Loading JNI bridge...")
        System.loadLibrary("qrpaymentsbridge")
        android.util.Log.d(TAG, "✅ JNI bridge loaded successfully!")
    }

    /**
     * Native method declarations - these map to Swift @_cdecl functions
     */
    @JvmStatic
    private external fun nativeGenerateSPAYD(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ): String

    @JvmStatic
    private external fun nativeConvertToIBAN(
        prefix: String,
        accountNumber: String,
        bankCode: String
    ): String

    /**
     * Generates SPAYD format string for Czech QR payment
     * Calls Swift SPAYDGenerator.generate() via JNI
     */
    fun generateSPAYD(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ): String {
        android.util.Log.d(TAG, "🚀 Calling Swift implementation via JNI")
        return nativeGenerateSPAYD(prefix, accountNumber, bankCode, amount, variableSymbol, message)
    }

    /**
     * Validates bank code (4 digits)
     * TODO: Add JNI bridge call to Swift Validator when needed
     */
    fun isValidBankCode(code: String): Boolean {
        return code.length == 4 && code.all { it.isDigit() }
    }

    /**
     * Validates account number (up to 10 digits)
     * TODO: Add JNI bridge call to Swift Validator when needed
     */
    fun isValidAccountNumber(number: String): Boolean {
        return number.isNotEmpty() && number.length <= 10 && number.all { it.isDigit() }
    }

    /**
     * Validates account prefix (optional, up to 6 digits)
     * TODO: Add JNI bridge call to Swift Validator when needed
     */
    fun isValidPrefix(prefix: String): Boolean {
        if (prefix.isEmpty()) return true
        return prefix.length <= 6 && prefix.all { it.isDigit() }
    }
}
