package com.qrpayments.bridge

import com.qrpayments.data.BankAccount

/**
 * Bridge to Swift QRPaymentsCore library via JNI
 * Calls native Swift functions exported with @_cdecl
 */
object SwiftBridge {

    private const val TAG = "SwiftBridge"
    private var isSwiftAvailable = false

    init {
        try {
            // IMPORTANT: Load Swift library FIRST, then JNI bridge
            // The JNI bridge depends on Swift library, so order matters
            android.util.Log.d(TAG, "Loading Swift library...")
            System.loadLibrary("QRPaymentsCore")
            android.util.Log.d(TAG, "✅ Swift library loaded successfully!")

            android.util.Log.d(TAG, "Loading JNI bridge...")
            System.loadLibrary("qrpaymentsbridge")
            android.util.Log.d(TAG, "✅ JNI bridge loaded successfully!")

            isSwiftAvailable = true
        } catch (e: UnsatisfiedLinkError) {
            android.util.Log.w(TAG, "⚠️ JNI bridge not available, using Kotlin fallback", e)
            isSwiftAvailable = false
        }
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
        return if (isSwiftAvailable) {
            try {
                android.util.Log.d(TAG, "🚀 Calling Swift implementation via JNI")
                nativeGenerateSPAYD(prefix, accountNumber, bankCode, amount, variableSymbol, message)
            } catch (e: UnsatisfiedLinkError) {
                android.util.Log.w(TAG, "⚠️ Swift call failed, using Kotlin fallback", e)
                generateSPAYDKotlin(prefix, accountNumber, bankCode, amount, variableSymbol, message)
            }
        } else {
            android.util.Log.d(TAG, "📱 Using Kotlin implementation (Swift not available)")
            generateSPAYDKotlin(prefix, accountNumber, bankCode, amount, variableSymbol, message)
        }
    }

    /**
     * Validates bank code (4 digits)
     */
    fun isValidBankCode(code: String): Boolean {
        // TODO: Replace with swift-java call to Swift Validator
        return code.length == 4 && code.all { it.isDigit() }
    }

    /**
     * Validates account number (up to 10 digits)
     */
    fun isValidAccountNumber(number: String): Boolean {
        // TODO: Replace with swift-java call to Swift Validator
        return number.isNotEmpty() && number.length <= 10 && number.all { it.isDigit() }
    }

    /**
     * Validates account prefix (optional, up to 6 digits)
     */
    fun isValidPrefix(prefix: String): Boolean {
        // TODO: Replace with swift-java call to Swift Validator
        if (prefix.isEmpty()) return true
        return prefix.length <= 6 && prefix.all { it.isDigit() }
    }

    /**
     * Temporary Kotlin implementation of SPAYD generation
     * This mirrors the Swift logic and will be replaced by swift-java bridge
     */
    private fun generateSPAYDKotlin(
        prefix: String,
        accountNumber: String,
        bankCode: String,
        amount: String?,
        variableSymbol: String?,
        message: String?
    ): String {
        val iban = convertToIBAN(prefix, accountNumber, bankCode)
        val components = mutableListOf<String>()

        // Required: Version and Account
        components.add("SPD*1.0")
        components.add("ACC:$iban")

        // Optional: Amount
        if (!amount.isNullOrEmpty()) {
            amount.toDoubleOrNull()?.let { amountValue ->
                if (amountValue > 0) {
                    components.add("AM:${"%.2f".format(amountValue)}")
                }
            }
        }

        // Required: Currency
        components.add("CC:CZK")

        // Optional: Message
        if (!message.isNullOrEmpty()) {
            val encodedMessage = message.replace(Regex("[^A-Za-z0-9]"), "")
            components.add("MSG:$encodedMessage")
        }

        // Optional: Variable Symbol
        if (!variableSymbol.isNullOrEmpty()) {
            components.add("X-VS:$variableSymbol")
        }

        return components.joinToString("*")
    }

    /**
     * Converts Czech account format to IBAN
     */
    private fun convertToIBAN(prefix: String, accountNumber: String, bankCode: String): String {
        // Pad prefix to 6 digits
        val paddedPrefix = if (prefix.isEmpty()) {
            "000000"
        } else {
            prefix.toIntOrNull()?.let { "%06d".format(it) } ?: "000000"
        }

        // Pad account number to 10 digits
        val paddedAccount = accountNumber.toIntOrNull()?.let { "%010d".format(it) } ?: "0000000000"

        // Combine bank code + prefix + account
        val bban = "$bankCode$paddedPrefix$paddedAccount"

        // Calculate IBAN check digits
        val checkDigits = calculateIBANCheckDigits("CZ", bban)

        return "CZ$checkDigits$bban"
    }

    /**
     * Calculates IBAN check digits using MOD 97 algorithm
     */
    private fun calculateIBANCheckDigits(countryCode: String, bban: String): String {
        // Move country code and 00 to the end
        val rearranged = bban + countryCode + "00"

        // Replace letters with numbers (A=10, B=11, ..., Z=35)
        val numericString = buildString {
            for (char in rearranged) {
                if (char.isLetter()) {
                    append(char.code - 'A'.code + 10)
                } else {
                    append(char)
                }
            }
        }

        // Calculate MOD 97
        var remainder = 0
        for (char in numericString) {
            remainder = (remainder * 10 + char.digitToInt()) % 97
        }

        val checkDigit = 98 - remainder
        return "%02d".format(checkDigit)
    }
}
