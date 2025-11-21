package com.qrpayments.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "accounts")

/**
 * Repository for managing bank accounts with local persistence
 * Uses DataStore for simple key-value storage
 */
class AccountsRepository(private val context: Context) {

    private val json = Json { ignoreUnknownKeys = true }
    private val accountsKey = stringPreferencesKey("bank_accounts")

    /**
     * Flow of all bank accounts
     */
    val accounts: Flow<List<BankAccount>> = context.dataStore.data
        .map { preferences ->
            val jsonString = preferences[accountsKey] ?: "[]"
            try {
                json.decodeFromString<List<SerializableBankAccount>>(jsonString)
                    .map { it.toBankAccount() }
            } catch (e: Exception) {
                emptyList()
            }
        }

    /**
     * Add a new bank account
     */
    suspend fun addAccount(account: BankAccount) {
        context.dataStore.edit { preferences ->
            val currentList = getCurrentAccounts(preferences)
            val updatedList = currentList + account
            preferences[accountsKey] = json.encodeToString(updatedList.map { it.toSerializable() })
        }
    }

    /**
     * Update an existing account
     */
    suspend fun updateAccount(account: BankAccount) {
        context.dataStore.edit { preferences ->
            val currentList = getCurrentAccounts(preferences)
            val updatedList = currentList.map {
                if (it.id == account.id) account else it
            }
            preferences[accountsKey] = json.encodeToString(updatedList.map { it.toSerializable() })
        }
    }

    /**
     * Delete an account
     */
    suspend fun deleteAccount(accountId: String) {
        context.dataStore.edit { preferences ->
            val currentList = getCurrentAccounts(preferences)
            val updatedList = currentList.filter { it.id != accountId }
            preferences[accountsKey] = json.encodeToString(updatedList.map { it.toSerializable() })
        }
    }

    /**
     * Get current accounts from preferences
     */
    private fun getCurrentAccounts(preferences: Preferences): List<BankAccount> {
        val jsonString = preferences[accountsKey] ?: "[]"
        return try {
            json.decodeFromString<List<SerializableBankAccount>>(jsonString)
                .map { it.toBankAccount() }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * Serializable version of BankAccount for JSON storage
     */
    @Serializable
    private data class SerializableBankAccount(
        val id: String,
        val name: String,
        val prefix: String,
        val accountNumber: String,
        val bankCode: String,
        val createdAt: Long
    )

    private fun BankAccount.toSerializable() = SerializableBankAccount(
        id = id,
        name = name,
        prefix = prefix,
        accountNumber = accountNumber,
        bankCode = bankCode,
        createdAt = createdAt
    )

    private fun SerializableBankAccount.toBankAccount() = BankAccount(
        id = id,
        name = name,
        prefix = prefix,
        accountNumber = accountNumber,
        bankCode = bankCode,
        createdAt = createdAt
    )
}
