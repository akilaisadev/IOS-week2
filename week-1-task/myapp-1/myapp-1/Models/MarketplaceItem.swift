//
//  MarketplaceItem.swift
//  myapp-1
//

import SwiftUI

enum MarketplaceCategory: String, Codable, CaseIterable, Identifiable {
    case powerUps = "Power-Ups"
    case boosters = "Boosters"
    case cosmetics = "Cosmetics"
    case avatars = "Avatars"
    case skins = "Skins"
    
    var id: String { rawValue }
}

struct MarketplaceItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: MarketplaceCategory
    let price: Int
    let badgeText: String?
    var isStackable: Bool = false
    var isSystemImage: Bool = true
}
