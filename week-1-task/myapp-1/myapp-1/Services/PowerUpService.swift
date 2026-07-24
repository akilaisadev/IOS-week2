//
//  PowerUpService.swift
//  myapp-1
//

import SwiftUI
import Combine

class PowerUpService: ObservableObject {
    static let shared = PowerUpService()
    
    @Published private(set) var activePowerUp: PowerUpType?
    
    private init() {}
    
    // Activates powerup for upcoming game if item is in inventory
    func activatePowerUp(_ type: PowerUpType) -> Bool {
        let itemID: String
        switch type {
        case .doubleCoins: itemID = "power_double_coins"
        case .scoreShield: itemID = "power_score_shield"
        case .timeFreezer: itemID = "power_time_freezer"
        }
        
        if MarketplaceService.shared.consumeItem(id: itemID) {
            activePowerUp = type
            return true
        }
        return false
    }
    
    func consumeActivePowerUp() -> PowerUpType? {
        let current = activePowerUp
        activePowerUp = nil
        return current
    }
    
    func clearActivePowerUp() {
        activePowerUp = nil
    }
}
