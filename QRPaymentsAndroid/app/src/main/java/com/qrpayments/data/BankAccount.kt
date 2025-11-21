package com.qrpayments.data

import java.util.Date
import java.util.UUID

/**
 * Android representation of BankAccount
 * Mirrors the Swift model from QRPaymentsCore
 */
data class BankAccount(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val prefix: String = "",
    val accountNumber: String,
    val bankCode: String,
    val createdAt: Long = System.currentTimeMillis()
) {
    /**
     * Formatted Czech account number: prefix-accountNumber/bankCode or accountNumber/bankCode
     */
    val formattedAccountNumber: String
        get() = if (prefix.isEmpty()) {
            "$accountNumber/$bankCode"
        } else {
            "$prefix-$accountNumber/$bankCode"
        }
}
