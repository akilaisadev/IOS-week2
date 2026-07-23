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
        
        MarketplaceItem(id: "frame_gold", name: "Gold Crown Frame", description: "Exclusive golden glow border for profile", iconName: "crown.fill", category: .cosmetics, price: 300, badgeText: "VIP", isStackable: false),
        MarketplaceItem(id: "frame_neon", name: "Neon Cyber Frame", description: "Vibrant neon ring frame", iconName: "bolt.fill", category: .cosmetics, price: 250, badgeText: "NEON", isStackable: false),
        MarketplaceItem(id: "frame_galaxy", name: "Galaxy Star Frame", description: "Cosmic stellar aura frame", iconName: "sparkles", category: .cosmetics, price: 400, badgeText: "STAR", isStackable: false)
    ]
    
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
    
    // Purchases marketplace item using WalletService balance
    func purchase(_ item: MarketplaceItem) -> Bool {
        if !item.isStackable && (ownedItems[item.id] ?? 0) > 0 {
            return false
        }
        
        let success = WalletService.shared.spendCoins(item.price)
        if success {
            ownedItems[item.id] = (ownedItems[item.id] ?? 0) + 1
            saveInventory()
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
