//
//  ReferralView.swift
//  myapp-1
//

import SwiftUI

struct ReferralView: View {
    @ObservedObject private var walletService = WalletService.shared
    @ObservedObject private var referralService = ReferralService.shared
    
    @State private var inputCode = ""
    @State private var alertMessage: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 70, height: 70)
                        Image(systemName: "person.2.gift.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.purple)
                    }
                    
                    Text("Invite Friends & Earn Coins")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Share your code with friends! When they redeem your code, you both earn 50 bonus GameCoins!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 10)
                
                VStack(spacing: 14) {
                    Text("YOUR REFERRAL CODE")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                    
                    Text(walletService.wallet.referralCode)
                        .font(.system(size: 34, weight: .black, design: .monospaced))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
                        )
                    
                    ShareLink(
                        item: "Join me on GameHub! Use my referral code \(walletService.wallet.referralCode) to get 50 free GameCoins!",
                        subject: Text("GameHub Referral Code"),
                        message: Text("Use code \(walletService.wallet.referralCode) for 50 bonus GameCoins!")
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Referral Code")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                VStack(spacing: 14) {
                    Text("REDEEM FRIEND'S CODE")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                    
                    if referralService.hasClaimedReward {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Referral Reward Claimed (+50 Coins)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .padding()
                    } else {
                        HStack {
                            TextField("Enter 6-digit Code", text: $inputCode)
                                .font(.system(.body, design: .monospaced))
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                            
                            Button("Redeem") {
                                handleRedeem()
                            }
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding(10)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Referral Program")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Referral", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }
    
    private func handleRedeem() {
        let result = referralService.redeemCode(inputCode)
        if result.success {
            SoundManager.shared.playBonus()
            inputCode = ""
        }
        alertMessage = result.message
    }
}

#Preview {
    NavigationStack {
        ReferralView()
    }
}
