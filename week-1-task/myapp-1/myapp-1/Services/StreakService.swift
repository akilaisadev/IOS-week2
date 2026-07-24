//
//  StreakService.swift
//  myapp-1
//

import SwiftUI
import Combine

class StreakService: ObservableObject {
    static let shared = StreakService()
    
    private let streakKey = "DailyStreakCountData"
    private let lastDateKey = "DailyStreakLastDateData"
    
    @Published private(set) var currentStreak: Int = 1
    @Published private(set) var todayRewardClaimed: Bool = false
    @Published var streakBannerMessage: String? = nil
    
    private init() {
        checkDailyStreak()
    }
    
    // Calculates consecutive daily login streak and awards bonus coins
    func checkDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        currentStreak = max(1, UserDefaults.standard.integer(forKey: streakKey))
        
        if let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                todayRewardClaimed = true
            } else if daysDifference == 1 {
                currentStreak += 1
                awardStreakBonus()
            } else if daysDifference > 1 {
                currentStreak = 1
                awardStreakBonus()
            }
        } else {
            awardStreakBonus()
        }
    }
    
    private func awardStreakBonus() {
        let bonusCoins = currentStreak * 10
        WalletService.shared.addCoins(bonusCoins)
        
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(Date(), forKey: lastDateKey)
        todayRewardClaimed = true
        
        withAnimation {
            streakBannerMessage = "🔥 Day \(currentStreak) Streak Bonus! +\(bonusCoins) Coins"
        }
    }
    
    func dismissBanner() {
        withAnimation {
            streakBannerMessage = nil
        }
    }
}
