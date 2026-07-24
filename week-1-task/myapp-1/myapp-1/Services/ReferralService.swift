//
//  ReferralService.swift
//  myapp-1
//

import SwiftUI
import Combine

class ReferralService: ObservableObject {
    static let shared = ReferralService()
    
    private let redeemedKey = "ReferralRedeemedCodesData"
    private let hasClaimedKey = "HasClaimedReferralReward"
    
    @Published private(set) var redeemedCodes: [String] = []
    @Published private(set) var hasClaimedReward: Bool = false
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: redeemedKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            redeemedCodes = decoded
        }
        hasClaimedReward = UserDefaults.standard.bool(forKey: hasClaimedKey)
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(redeemedCodes) {
            UserDefaults.standard.set(encoded, forKey: redeemedKey)
        }
        UserDefaults.standard.set(hasClaimedReward, forKey: hasClaimedKey)
    }
    
    // Validates friend referral code and awards 50 coins
    func redeemCode(_ code: String) -> (success: Bool, message: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard trimmed.count == 6 else {
            return (false, "Invalid referral code format. Code must be 6 characters.")
        }
        
        guard trimmed != WalletService.shared.wallet.referralCode else {
            return (false, "You cannot redeem your own referral code!")
        }
        
        guard !hasClaimedReward else {
            return (false, "You have already redeemed a referral reward.")
        }
        
        hasClaimedReward = true
        redeemedCodes.append(trimmed)
        saveData()
        
        WalletService.shared.addCoins(50)
        AchievementService.shared.unlock("ach_referral_champion")
        
        return (true, "Success! You earned 50 bonus coins!")
    }
}
