package com.qrpayments.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
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
    val context = LocalContext.current
    val viewModel: AccountsViewModel = viewModel(
        factory = AccountsViewModelFactory(context.applicationContext as android.app.Application)
    )

    NavHost(
        navController = navController,
        startDestination = "accounts_list"
    ) {
        // Main accounts list screen
        composable("accounts_list") {
            AccountsListScreen(
                viewModel = viewModel,
                onAddAccount = {
                    navController.navigate("account_form_new")
                },
                onEditAccount = { accountId ->
                    navController.navigate("account_form_edit/$accountId")
                },
                onGenerateQR = { accountId ->
                    navController.navigate("qr_generation/$accountId")
                }
            )
        }

        // Account form - Add new account
        composable("account_form_new") {
            AccountFormScreen(
                viewModel = viewModel,
                accountId = null,
                isEditMode = false,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        // Account form - Edit existing account
        composable(
            route = "account_form_edit/{accountId}",
            arguments = listOf(
                navArgument("accountId") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val accountId = backStackEntry.arguments?.getString("accountId")

            AccountFormScreen(
                viewModel = viewModel,
                accountId = accountId,
                isEditMode = true,
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
