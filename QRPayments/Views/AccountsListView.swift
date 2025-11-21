//
//  AccountsListView.swift
//  QRPayments
//
//  Displays list of all bank accounts with Liquid Glass design
//
//  Created on 2025-11-20
//

import SwiftUI
import SwiftData

struct AccountsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BankAccount.createdAt, order: .reverse) private var accounts: [BankAccount]
    @State private var showingNewAccount = false
    @State private var accountToEdit: BankAccount?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.5, blue: 0.9),
                        Color(red: 0.2, green: 0.3, blue: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        // QR Pay branding
                        HStack {
                            Text("QR Pay")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        // Create new account card - only shown when no accounts exist
                        if accounts.isEmpty {
                            Button {
                                showingNewAccount = true
                            } label: {
                                ZStack {
                                    // Liquid Glass background
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        }
                                        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)

                                    VStack(spacing: 16) {
                                        // QR code icon
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color.white.opacity(0.9))
                                                .frame(width: 120, height: 120)

                                            Image(systemName: "qrcode")
                                                .font(.system(size: 64))
                                                .foregroundStyle(.blue)
                                        }

                                        VStack(spacing: 4) {
                                            Text("Press to create")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(.white)

                                            Text("new Account card.")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(.white)
                                        }

                                        Text("Take simple and quick way to pay.\nWe support all banks on the market.")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(4)
                                    }
                                    .padding(24)
                                }
                                .frame(height: 280)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, accounts.isEmpty ? 24 : 16)

                    // Accounts list section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Accounts list")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)

                        ScrollView {
                            LazyVStack(spacing: 16) {
                                if accounts.isEmpty {
                                    // Empty state
                                    Text("No accounts yet")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 40)
                                } else {
                                    ForEach(accounts) { account in
                                        NavigationLink(destination: QRGenerationView(account: account)) {
                                            AccountCardView(account: account)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteAccount(account)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .contextMenu {
                                            Button {
                                                accountToEdit = account
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }

                                            Button(role: .destructive) {
                                                deleteAccount(account)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .toolbar {
                // Show plus button only when accounts exist
                if !accounts.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingNewAccount = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewAccount) {
                NewAccountView()
            }
            .sheet(item: $accountToEdit) { account in
                EditAccountView(account: account)
            }
        }
    }

    private func deleteAccount(_ account: BankAccount) {
        withAnimation {
            modelContext.delete(account)
            try? modelContext.save()
        }
    }
}

// MARK: - Account Card View
struct AccountCardView: View {
    let account: BankAccount

    var body: some View {
        ZStack {
            // Liquid Glass background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.1), radius: 15, y: 8)

            HStack(spacing: 16) {
                // Bank logo placeholder
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 56, height: 56)

                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(account.formattedAccountNumber)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(20)
        }
        .frame(height: 96)
    }
}

#Preview {
    AccountsListView()
        .modelContainer(for: BankAccount.self, inMemory: true)
}
