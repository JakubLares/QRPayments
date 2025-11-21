package com.qrpayments.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.qrpayments.bridge.SwiftBridge
import com.qrpayments.data.BankAccount
import com.qrpayments.ui.AccountsViewModel
import com.qrpayments.ui.theme.BackgroundGradientEnd
import com.qrpayments.ui.theme.BackgroundGradientStart

/**
 * Screen for adding or editing a bank account
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AccountFormScreen(
    viewModel: AccountsViewModel,
    accountId: String?,
    isEditMode: Boolean,
    onNavigateBack: () -> Unit
) {
    val accounts by viewModel.accounts.collectAsState()
    val existingAccount = accounts.find { it.id == accountId }

    var name by remember { mutableStateOf(existingAccount?.name ?: "") }
    var prefix by remember { mutableStateOf(existingAccount?.prefix ?: "") }
    var accountNumber by remember { mutableStateOf(existingAccount?.accountNumber ?: "") }
    var bankCode by remember { mutableStateOf(existingAccount?.bankCode ?: "") }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (isEditMode) "Edit Account" else "Add Account",
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            Icons.Default.ArrowBack,
                            contentDescription = "Back",
                            tint = Color.White
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = Color.White
                )
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            BackgroundGradientStart,
                            BackgroundGradientEnd
                        )
                    )
                )
                .padding(padding)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = Color.White.copy(alpha = 0.95f)
                    )
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // Account Name
                        OutlinedTextField(
                            value = name,
                            onValueChange = { name = it },
                            label = { Text("Account Name") },
                            placeholder = { Text("e.g., My Main Account") },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true
                        )

                        // Prefix
                        OutlinedTextField(
                            value = prefix,
                            onValueChange = { if (it.length <= 6) prefix = it },
                            label = { Text("Prefix (optional)") },
                            placeholder = { Text("6 digits max") },
                            modifier = Modifier.fillMaxWidth(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            singleLine = true
                        )

                        // Account Number
                        OutlinedTextField(
                            value = accountNumber,
                            onValueChange = { if (it.length <= 10) accountNumber = it },
                            label = { Text("Account Number") },
                            placeholder = { Text("10 digits") },
                            modifier = Modifier.fillMaxWidth(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            singleLine = true
                        )

                        // Bank Code
                        OutlinedTextField(
                            value = bankCode,
                            onValueChange = { if (it.length <= 4) bankCode = it },
                            label = { Text("Bank Code") },
                            placeholder = { Text("4 digits (e.g., 0800)") },
                            modifier = Modifier.fillMaxWidth(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            singleLine = true
                        )

                        // Error message
                        if (errorMessage != null) {
                            Text(
                                text = errorMessage!!,
                                color = MaterialTheme.colorScheme.error,
                                style = MaterialTheme.typography.bodySmall
                            )
                        }

                        // Save button
                        Button(
                            onClick = {
                                // Validate using Swift bridge
                                if (name.isEmpty()) {
                                    errorMessage = "Account name is required"
                                    return@Button
                                }

                                if (!SwiftBridge.isValidPrefix(prefix)) {
                                    errorMessage = "Invalid prefix format"
                                    return@Button
                                }

                                if (!SwiftBridge.isValidAccountNumber(accountNumber)) {
                                    errorMessage = "Invalid account number"
                                    return@Button
                                }

                                if (!SwiftBridge.isValidBankCode(bankCode)) {
                                    errorMessage = "Bank code must be exactly 4 digits"
                                    return@Button
                                }

                                // Save account
                                val account = BankAccount(
                                    id = existingAccount?.id ?: java.util.UUID.randomUUID().toString(),
                                    name = name,
                                    prefix = prefix,
                                    accountNumber = accountNumber,
                                    bankCode = bankCode,
                                    createdAt = existingAccount?.createdAt ?: System.currentTimeMillis()
                                )

                                if (isEditMode) {
                                    viewModel.updateAccount(account)
                                } else {
                                    viewModel.addAccount(account)
                                }

                                onNavigateBack()
                            },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
}
