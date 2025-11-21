package com.qrpayments.ui

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.qrpayments.data.AccountsRepository
import com.qrpayments.data.BankAccount
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/**
 * ViewModel for managing bank accounts
 */
class AccountsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = AccountsRepository(application)

    val accounts: StateFlow<List<BankAccount>> = repository.accounts
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    fun addAccount(account: BankAccount) {
        viewModelScope.launch {
            repository.addAccount(account)
        }
    }

    fun updateAccount(account: BankAccount) {
        viewModelScope.launch {
            repository.updateAccount(account)
        }
    }

    fun deleteAccount(accountId: String) {
        viewModelScope.launch {
            repository.deleteAccount(accountId)
        }
    }
}
