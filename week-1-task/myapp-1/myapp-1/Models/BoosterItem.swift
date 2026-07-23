//
//  BoosterItem.swift
//  myapp-1
//

import SwiftUI

enum BoosterType: String, Codable, CaseIterable, Identifiable {
    case lifeRefill = "Life Refill"
    case timeSurge = "Time Surge"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .lifeRefill: return "Refills +1 heart mid-game when low on lives (Light It Up only)"
        case .timeSurge: return "Extends game clock by +5 seconds mid-round (Tap Frenzy & Light It Up)"
        }
    }
    
    var iconName: String {
        switch self {
        case .lifeRefill: return "heart.circle.fill"
        case .timeSurge: return "bolt.circle.fill"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .lifeRefill: return .red
        case .timeSurge: return .orange
        }
    }
}
