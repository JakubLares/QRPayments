package com.qrpayments

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.qrpayments.ui.QRPaymentsApp
import com.qrpayments.ui.theme.QRPaymentsTheme

/**
 * Main entry point for the QR Payments Android app
 * Built with Jetpack Compose and Swift business logic
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            QRPaymentsTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    QRPaymentsApp()
                }
            }
        }
    }
}
