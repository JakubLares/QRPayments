package com.qrpayments.ui

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider

/**
 * Factory for creating AccountsViewModel with Application parameter
 */
class AccountsViewModelFactory(
    private val application: Application
) : ViewModelProvider.Factory {

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(AccountsViewModel::class.java)) {
            return AccountsViewModel(application) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
