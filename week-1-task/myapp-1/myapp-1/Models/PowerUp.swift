//
//  PowerUp.swift
//  myapp-1
//

import SwiftUI

enum PowerUpType: String, Codable, CaseIterable, Identifiable {
    case doubleCoins = "Double Coins"
    case scoreShield = "Score Shield"
    case timeFreezer = "Time Freezer"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .doubleCoins: return "Doubles coins earned from your next game session"
        case .scoreShield: return "Ignores 1 red trap penalty in Tap Frenzy"
        case .timeFreezer: return "Adds +5 extra seconds to game timer start"
        }
    }
    
    var iconName: String {
        switch self {
        case .doubleCoins: return "dollarsign.circle.fill"
        case .scoreShield: return "shield.fill"
        case .timeFreezer: return "hourglass.bottomhalf.fill"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .doubleCoins: return .green
        case .scoreShield: return .blue
        case .timeFreezer: return .purple
        }
    }
}
