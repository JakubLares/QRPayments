package com.qrpayments.ui.screens

import android.graphics.Bitmap
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.qrpayments.bridge.SwiftBridge
import com.qrpayments.ui.AccountsViewModel
import com.qrpayments.ui.theme.BackgroundGradientEnd
import com.qrpayments.ui.theme.BackgroundGradientStart
import com.qrpayments.util.QRCodeGenerator

/**
 * Screen for generating QR codes with payment details
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QRGenerationScreen(
    viewModel: AccountsViewModel,
    accountId: String,
    onNavigateBack: () -> Unit
) {
    val accounts by viewModel.accounts.collectAsState()
    val account = accounts.find { it.id == accountId }

    var amount by remember { mutableStateOf("") }
    var variableSymbol by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var qrCodeBitmap by remember { mutableStateOf<Bitmap?>(null) }
    var showQRDialog by remember { mutableStateOf(false) }

    if (account == null) {
        // Account not found
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text("Account not found")
        }
        return
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Generate QR Code",
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
                // Account info card
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = Color.White.copy(alpha = 0.95f)
                    )
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp)
                    ) {
                        Text(
                            account.name,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            account.formattedAccountNumber,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }
                }

                // Payment details card
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
                        Text(
                            "Payment Details",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )

                        // Amount
                        OutlinedTextField(
                            value = amount,
                            onValueChange = { amount = it },
                            label = { Text("Amount (CZK)") },
                            placeholder = { Text("Optional") },
                            modifier = Modifier.fillMaxWidth(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                            singleLine = true
                        )

                        // Variable Symbol
                        OutlinedTextField(
                            value = variableSymbol,
                            onValueChange = { if (it.length <= 10) variableSymbol = it },
                            label = { Text("Variable Symbol") },
                            placeholder = { Text("Optional reference number") },
                            modifier = Modifier.fillMaxWidth(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            singleLine = true
                        )

                        // Message
                        OutlinedTextField(
                            value = message,
                            onValueChange = { message = it },
                            label = { Text("Message") },
                            placeholder = { Text("Optional message for receiver") },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true
                        )

                        // Generate button
                        Button(
                            onClick = {
                                // Generate SPAYD string using Swift bridge
                                val spaydString = SwiftBridge.generateSPAYD(
                                    prefix = account.prefix,
                                    accountNumber = account.accountNumber,
                                    bankCode = account.bankCode,
                                    amount = amount.ifEmpty { null },
                                    variableSymbol = variableSymbol.ifEmpty { null },
                                    message = message.ifEmpty { null }
                                )

                                // Generate QR code
                                qrCodeBitmap = QRCodeGenerator.generate(spaydString, 512)
                                showQRDialog = true
                            },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Icon(Icons.Default.QrCode, contentDescription = null)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Generate QR Code")
                        }
                    }
                }
            }
        }
    }

    // QR Code Dialog
    if (showQRDialog && qrCodeBitmap != null) {
        AlertDialog(
            onDismissRequest = { showQRDialog = false },
            title = {
                Text(
                    "QR Payment Code",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Image(
                        bitmap = qrCodeBitmap!!.asImageBitmap(),
                        contentDescription = "QR Code",
                        modifier = Modifier.size(280.dp)
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        account.name,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        account.formattedAccountNumber,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )
                    if (amount.isNotEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            "$amount CZK",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Scan this QR code with your banking app to make a payment",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            },
            confirmButton = {
                TextButton(onClick = { showQRDialog = false }) {
                    Text("Close")
                }
            }
        )
    }
}
