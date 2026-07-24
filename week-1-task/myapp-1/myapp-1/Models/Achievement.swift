//
//  Achievement.swift
//  myapp-1
//

import SwiftUI

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let coinReward: Int
    var isUnlocked: Bool = false
    var unlockedDate: Date? = nil
}
