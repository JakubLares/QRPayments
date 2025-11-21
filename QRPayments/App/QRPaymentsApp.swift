//
//  QRPaymentsApp.swift
//  QRPayments
//
//  Created on 2025-11-20
//

import SwiftUI
import SwiftData

@main
struct QRPaymentsApp: App {
    var body: some Scene {
        WindowGroup {
            AccountsListView()
        }
        .modelContainer(for: BankAccount.self)
    }
}
