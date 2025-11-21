//
//  QRGenerationView.swift
//  QRPayments
//
//  Generates QR code for payment with Liquid Glass design
//
//  Created on 2025-11-20
//

import SwiftUI

struct QRGenerationView: View {
    let account: BankAccount

    @State private var amount: String = ""
    @State private var variableSymbol: String = ""
    @State private var message: String = ""
    @State private var qrCodeImage: UIImage?
    @State private var showingQRCode = false

    var body: some View {
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
                    // Bank Account Header
                    VStack(spacing: 12) {
                        // Bank logo placeholder
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                }
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.1), radius: 15, y: 8)

                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.white)
                        }

                        VStack(spacing: 4) {
                            Text(account.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(account.formattedAccountNumber)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 20)

                    // Payment Form Card
                    VStack(spacing: 20) {
                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("INSERT AMOUNT INTO PAY")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                                .tracking(0.5)

                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    }

                                HStack {
                                    TextField("", text: $amount, prompt: Text("900 CZK").foregroundColor(.white.opacity(0.4)))
                                        .textFieldStyle(.plain)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18, weight: .semibold))
                                        .keyboardType(.decimalPad)
                                        .padding(.leading, 16)

                                    Text("CZK")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .padding(.trailing, 16)
                                }
                            }
                            .frame(height: 56)
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Variable Symbol Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("VARIABLE SYMBOL")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                                .tracking(0.5)

                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    }

                                TextField("", text: $variableSymbol, prompt: Text("Optional").foregroundColor(.white.opacity(0.4)))
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .semibold))
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal, 16)
                            }
                            .frame(height: 56)
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Message Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MESSAGE FOR RECEIVER")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                                .tracking(0.5)

                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    }

                                TextEditor(text: $message)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 14)

                                if message.isEmpty {
                                    Text("Optional")
                                        .foregroundStyle(.white.opacity(0.4))
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 22)
                                        .allowsHitTesting(false)
                                }
                            }
                            .frame(height: 100)
                        }

                        // Generate QR Button
                        Button {
                            generateQRCode()
                        } label: {
                            Text("Generate QR Code")
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
        .sheet(isPresented: $showingQRCode) {
            QRCodeDisplayView(
                qrCodeImage: qrCodeImage,
                account: account,
                amount: amount
            )
        }
    }

    private func generateQRCode() {
        // Generate SPAYD string
        let spaydString = SPAYDGenerator.generate(
            prefix: account.prefix,
            accountNumber: account.accountNumber,
            bankCode: account.bankCode,
            amount: amount.isEmpty ? nil : amount,
            variableSymbol: variableSymbol.isEmpty ? nil : variableSymbol,
            message: message.isEmpty ? nil : message
        )

        // Generate QR code
        qrCodeImage = QRCodeGenerator.generate(from: spaydString)
        showingQRCode = true
    }
}

// MARK: - QR Code Display View
struct QRCodeDisplayView: View {
    let qrCodeImage: UIImage?
    let account: BankAccount
    let amount: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
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

            VStack(spacing: 32) {
                // Close button
                HStack {
                    Spacer()
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
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // QR Code Card
                VStack(spacing: 24) {
                    Text("Your personal QR pay code")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)

                    // Bank name
                    Text(account.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Account number
                    Text(account.formattedAccountNumber)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))

                    // Amount
                    if !amount.isEmpty {
                        Text("\(amount) CZK")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    // QR Code
                    if let qrCodeImage = qrCodeImage {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 280, height: 280)
                                .shadow(color: .black.opacity(0.2), radius: 30, y: 15)

                            Image(uiImage: qrCodeImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 240)
                        }
                    }

                    Text("Scan this QR code with your banking app")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 25, y: 12)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        QRGenerationView(account: BankAccount(
            name: "Equa Bank - Family Account",
            prefix: "19",
            accountNumber: "2121134949",
            bankCode: "6100"
        ))
    }
}
