//
//  MarketplaceService.swift
//  myapp-1
//

import SwiftUI
import Combine

class MarketplaceService: ObservableObject {
    static let shared = MarketplaceService()
    
    private let inventoryKey = "MarketplaceInventoryData"
    @Published private(set) var ownedItems: [String: Int] = [:]
    
    let catalogue: [MarketplaceItem] = [
        MarketplaceItem(id: "power_double_coins", name: "Double Coins", description: "Doubles coins earned from next game session", iconName: "dollarsign.circle.fill", category: .powerUps, price: 150, badgeText: "2X", isStackable: true),
        MarketplaceItem(id: "power_score_shield", name: "Score Shield", description: "Blocks 1 trap penalty in Tap Frenzy", iconName: "shield.fill", category: .powerUps, price: 100, badgeText: "SHIELD", isStackable: true),
        MarketplaceItem(id: "power_time_freezer", name: "Time Freezer", description: "Adds +5s extra time to next game start", iconName: "hourglass.bottomhalf.fill", category: .powerUps, price: 120, badgeText: "+5S", isStackable: true),
        
        MarketplaceItem(id: "booster_life_refill", name: "Life Refill", description: "Restores +1 heart mid-game in Light It Up", iconName: "heart.circle.fill", category: .boosters, price: 80, badgeText: "+1 HEART", isStackable: true),
        MarketplaceItem(id: "booster_time_surge", name: "Time Surge", description: "Adds +5 seconds clock surge mid-round", iconName: "bolt.circle.fill", category: .boosters, price: 60, badgeText: "SURGE", isStackable: true),
        MarketplaceItem(id: "booster_reveal_answer", name: "Reveal Answer", description: "Reveals the correct answer in Quiz Rush", iconName: "eye.fill", category: .boosters, price: 100, badgeText: "REVEAL", isStackable: true),
        
        MarketplaceItem(id: "frame_gold", name: "Gold Crown Frame", description: "Exclusive golden glow border for profile", iconName: "crown.fill", category: .cosmetics, price: 300, badgeText: "VIP", isStackable: false),
        MarketplaceItem(id: "frame_neon", name: "Neon Cyber Frame", description: "Vibrant neon ring frame", iconName: "bolt.fill", category: .cosmetics, price: 250, badgeText: "NEON", isStackable: false),
        MarketplaceItem(id: "frame_galaxy", name: "Galaxy Star Frame", description: "Cosmic stellar aura frame", iconName: "sparkles", category: .cosmetics, price: 400, badgeText: "STAR", isStackable: false),
        
        // Avatars (10)
        MarketplaceItem(id: "avatar_smile", name: "Smiley", description: "Classic smiling face", iconName: "face.smiling.fill", category: .avatars, price: 50, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_tortoise", name: "Tortoise", description: "Slow but steady wins the race", iconName: "tortoise.fill", category: .avatars, price: 75, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_ladybug", name: "Ladybug", description: "Bring some good luck", iconName: "ladybug.fill", category: .avatars, price: 75, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_ant", name: "Ant", description: "Hard worker", iconName: "ant.fill", category: .avatars, price: 75, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_hare", name: "Hare", description: "Fast and furious", iconName: "hare.fill", category: .avatars, price: 100, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_bird", name: "Bird", description: "Fly high", iconName: "bird.fill", category: .avatars, price: 100, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_pawprint", name: "Pawprint", description: "Animal lover", iconName: "pawprint.fill", category: .avatars, price: 50, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_mustache", name: "Mustache", description: "Very distinguished", iconName: "mustache.fill", category: .avatars, price: 150, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_eyes", name: "Eyes", description: "Always watching", iconName: "eyes.inverse", category: .avatars, price: 150, badgeText: "AVATAR", isStackable: false),
        MarketplaceItem(id: "avatar_brain", name: "Brain", description: "Big brain energy", iconName: "brain", category: .avatars, price: 200, badgeText: "AVATAR", isStackable: false),
        
        // Tap Frenzy Skins
        MarketplaceItem(id: "skin_bomb", name: "Bomb Skin", description: "An explosive tap target", iconName: "flame.fill", category: .skins, price: 150, badgeText: "SKIN", isStackable: false),
        MarketplaceItem(id: "skin_lightning", name: "Lightning Skin", description: "A shockingly fast target", iconName: "bolt.fill", category: .skins, price: 200, badgeText: "SKIN", isStackable: false)
    ]
    
    @AppStorage("activeAvatarId") var activeAvatarId = "person.fill"
    @AppStorage("activeTapFrenzySkinId") var activeTapFrenzySkinId = "hand.tap.fill"
    
    private init() {
        loadInventory()
    }
    
    private func loadInventory() {
        if let data = UserDefaults.standard.data(forKey: inventoryKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            ownedItems = decoded
        }
    }
    
    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(ownedItems) {
            UserDefaults.standard.set(encoded, forKey: inventoryKey)
        }
    }
    
    @AppStorage("totalItemsPurchased") private var totalItemsPurchased = 0
    
    // Purchases marketplace item using WalletService balance
    func purchase(_ item: MarketplaceItem) -> Bool {
        if !item.isStackable && (ownedItems[item.id] ?? 0) > 0 {
            return false
        }
        
        let success = WalletService.shared.spendCoins(item.price)
        if success {
            ownedItems[item.id] = (ownedItems[item.id] ?? 0) + 1
            saveInventory()
            
            totalItemsPurchased += 1
            if totalItemsPurchased >= 5 {
                AchievementService.shared.unlock("ach_marketplace_spender")
            }
            return true
        }
        return false
    }
    
    func quantity(for itemID: String) -> Int {
        ownedItems[itemID] ?? 0
    }
    
    func consumeItem(id: String) -> Bool {
        guard let count = ownedItems[id], count > 0 else { return false }
        if count == 1 {
            ownedItems.removeValue(forKey: id)
        } else {
            ownedItems[id] = count - 1
        }
        saveInventory()
        return true
    }
}
