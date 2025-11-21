//
//  EditAccountView.swift
//  QRPayments
//
//  Form to edit an existing bank account with Liquid Glass design
//
//  Created on 2025-11-20
//

import SwiftUI
import SwiftData

struct EditAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let account: BankAccount

    @State private var accountName: String = ""
    @State private var prefix: String = ""
    @State private var accountNumber: String = ""
    @State private var bankCode: String = ""

    @State private var showingError = false
    @State private var errorMessage = ""

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

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Edit Account")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Update account information")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)

                        // Form card
                        VStack(spacing: 20) {
                            // Account Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Account Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))

                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        }

                                    TextField("", text: $accountName, prompt: Text("Account name").foregroundColor(.white.opacity(0.4)))
                                        .textFieldStyle(.plain)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                }
                                .frame(height: 50)
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Czech Account Number Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    // Prefix
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Prefix")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.8))

                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(.ultraThinMaterial)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                }

                                            TextField("", text: $prefix, prompt: Text("1234").foregroundColor(.white.opacity(0.4)))
                                                .textFieldStyle(.plain)
                                                .foregroundStyle(.white)
                                                .keyboardType(.numberPad)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 14)
                                        }
                                        .frame(height: 50)
                                    }
                                    .frame(width: 100)

                                    // Account Number
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Acc. Number")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.8))

                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(.ultraThinMaterial)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                }

                                            TextField("", text: $accountNumber, prompt: Text("1234567891").foregroundColor(.white.opacity(0.4)))
                                                .textFieldStyle(.plain)
                                                .foregroundStyle(.white)
                                                .keyboardType(.numberPad)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 14)
                                        }
                                        .frame(height: 50)
                                    }

                                    // Bank Code
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Code")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.8))

                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(.ultraThinMaterial)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                }

                                            TextField("", text: $bankCode, prompt: Text("2100").foregroundColor(.white.opacity(0.4)))
                                                .textFieldStyle(.plain)
                                                .foregroundStyle(.white)
                                                .keyboardType(.numberPad)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 14)
                                        }
                                        .frame(height: 50)
                                    }
                                    .frame(width: 90)
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Save Changes Button
                            Button {
                                saveChanges()
                            } label: {
                                Text("Save Changes")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.blue)
                                    )
                            }
                        }
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                }
                                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            // Populate fields with existing account data
            accountName = account.name
            prefix = account.prefix
            accountNumber = account.accountNumber
            bankCode = account.bankCode
        }
    }

    private func saveChanges() {
        // Validate inputs
        guard !accountName.isEmpty else {
            errorMessage = "Please enter an account name"
            showingError = true
            return
        }

        guard !accountNumber.isEmpty else {
            errorMessage = "Please enter an account number"
            showingError = true
            return
        }

        guard !bankCode.isEmpty else {
            errorMessage = "Please enter a bank code"
            showingError = true
            return
        }

        // Validate bank code (should be 4 digits)
        guard bankCode.count == 4, bankCode.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Bank code must be exactly 4 digits"
            showingError = true
            return
        }

        // Update the account
        account.name = accountName
        account.prefix = prefix
        account.accountNumber = accountNumber
        account.bankCode = bankCode

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to update account: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    EditAccountView(account: BankAccount(
        name: "Test Account",
        prefix: "19",
        accountNumber: "1046683016",
        bankCode: "3030"
    ))
    .modelContainer(for: BankAccount.self, inMemory: true)
}
