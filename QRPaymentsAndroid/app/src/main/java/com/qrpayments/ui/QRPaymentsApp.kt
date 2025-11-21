package com.qrpayments.ui

import androidx.compose.runtime.Composable
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.qrpayments.ui.screens.AccountFormScreen
import com.qrpayments.ui.screens.AccountsListScreen
import com.qrpayments.ui.screens.QRGenerationScreen

/**
 * Main app navigation structure
 */
@Composable
fun QRPaymentsApp() {
    val navController = rememberNavController()
    val viewModel: AccountsViewModel = viewModel()

    NavHost(
        navController = navController,
        startDestination = "accounts_list"
    ) {
        // Main accounts list screen
        composable("accounts_list") {
            AccountsListScreen(
                viewModel = viewModel,
                onAddAccount = {
                    navController.navigate("account_form/new")
                },
                onEditAccount = { accountId ->
                    navController.navigate("account_form/edit/$accountId")
                },
                onGenerateQR = { accountId ->
                    navController.navigate("qr_generation/$accountId")
                }
            )
        }

        // Account form (add/edit)
        composable(
            route = "account_form/{mode}/{accountId}",
            arguments = listOf(
                navArgument("mode") { type = NavType.StringType },
                navArgument("accountId") {
                    type = NavType.StringType
                    nullable = true
                    defaultValue = null
                }
            )
        ) { backStackEntry ->
            val mode = backStackEntry.arguments?.getString("mode") ?: "new"
            val accountId = backStackEntry.arguments?.getString("accountId")

            AccountFormScreen(
                viewModel = viewModel,
                accountId = accountId,
                isEditMode = mode == "edit",
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        // QR code generation screen
        composable(
            route = "qr_generation/{accountId}",
            arguments = listOf(
                navArgument("accountId") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val accountId = backStackEntry.arguments?.getString("accountId")

            QRGenerationScreen(
                viewModel = viewModel,
                accountId = accountId ?: "",
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
