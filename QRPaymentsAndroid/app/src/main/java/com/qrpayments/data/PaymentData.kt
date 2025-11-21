package com.qrpayments.data

/**
 * Payment information for generating QR codes
 * Mirrors the Swift PaymentData model
 */
data class PaymentData(
    val account: BankAccount,
    val amount: String? = null,
    val variableSymbol: String? = null,
    val message: String? = null
)
