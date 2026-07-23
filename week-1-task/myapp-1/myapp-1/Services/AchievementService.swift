//
//  AchievementService.swift
//  myapp-1
//

import SwiftUI
import Combine

class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    private let storageKey = "AchievementsUnlockedData"
    
    @Published private(set) var achievements: [Achievement] = []
    @Published var recentlyUnlocked: Achievement? = nil
    
    private init() {
        setupAchievements()
        loadUnlockedState()
    }
    
    private func setupAchievements() {
        achievements = [
            Achievement(id: "ach_first_game", title: "First Step", description: "Complete your first game session", iconName: "play.circle.fill", coinReward: 20),
            Achievement(id: "ach_score_50", title: "Rising Star", description: "Score 50+ points in any game", iconName: "star.fill", coinReward: 30),
            Achievement(id: "ach_score_100", title: "Century Club", description: "Score 100+ points in a single session", iconName: "crown.fill", coinReward: 75),
            Achievement(id: "ach_tap_frenzy_master", title: "Tap Legend", description: "Score 40+ points in Tap Frenzy", iconName: "hand.tap.fill", coinReward: 50),
            Achievement(id: "ach_light_it_up_master", title: "Reflex King", description: "Score 30+ points in Light It Up", iconName: "sparkles", coinReward: 50),
            Achievement(id: "ach_quiz_master", title: "Brainiac", description: "Score 10+ correct answers in Quiz Rush", iconName: "brain.head.profile", coinReward: 50),
            Achievement(id: "ach_10_games", title: "Dedicated Gamer", description: "Play 10 total game sessions", iconName: "gamecontroller.fill", coinReward: 100),
            Achievement(id: "ach_50_games", title: "Marathon Gamer", description: "Play 50 total game sessions", iconName: "timer", coinReward: 200),
            Achievement(id: "ach_referral_champion", title: "Social Butterfly", description: "Successfully refer a friend", iconName: "person.2.fill", coinReward: 50),
            Achievement(id: "ach_score_200", title: "High Roller", description: "Score 200+ points in a single session", iconName: "flame.fill", coinReward: 150),
            Achievement(id: "ach_quiz_master_pro", title: "Einstein", description: "Score 20+ correct answers in Quiz Rush", iconName: "brain", coinReward: 100),
            Achievement(id: "ach_marketplace_spender", title: "Big Spender", description: "Make 5 purchases in the marketplace", iconName: "cart.fill", coinReward: 100)
        ]
    }
    
    private func loadUnlockedState() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedIDs = try? JSONDecoder().decode([String: Date].self, from: data) {
            for index in achievements.indices {
                if let date = savedIDs[achievements[index].id] {
                    achievements[index].isUnlocked = true
                    achievements[index].unlockedDate = date
                }
            }
        }
    }
    
    private func saveUnlockedState() {
        var dictionary: [String: Date] = [:]
        for ach in achievements where ach.isUnlocked {
            dictionary[ach.id] = ach.unlockedDate ?? Date()
        }
        if let encoded = try? JSONEncoder().encode(dictionary) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    // Evaluates session results to unlock achievements and award coins
    func checkSessionAchievements(session: GameSession, totalGamesPlayed: Int) {
        unlock("ach_first_game")
        
        if session.score >= 50 { unlock("ach_score_50") }
        if session.score >= 100 { unlock("ach_score_100") }
        if session.score >= 200 { unlock("ach_score_200") }
        
        switch session.mode {
        case .tapFrenzy:
            if session.score >= 40 { unlock("ach_tap_frenzy_master") }
        case .lightItUp:
            if session.score >= 30 { unlock("ach_light_it_up_master") }
        case .quizRush:
            if session.score >= 10 { unlock("ach_quiz_master") }
            if session.score >= 20 { unlock("ach_quiz_master_pro") }
        }
        
        if totalGamesPlayed >= 10 { unlock("ach_10_games") }
        if totalGamesPlayed >= 50 { unlock("ach_50_games") }
    }
    
    func unlock(_ achievementID: String) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementID }),
              !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        saveUnlockedState()
        
        WalletService.shared.addCoins(achievements[index].coinReward)
        
        withAnimation {
            recentlyUnlocked = achievements[index]
        }
    }
    
    func dismissToast() {
        withAnimation {
            recentlyUnlocked = nil
        }
    }
}
