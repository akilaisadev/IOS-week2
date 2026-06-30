//
//  GameRecord.swift
//  myapp-1
//
//  Codable model representing a completed game session stored in local storage.
//

import SwiftUI

enum GameType: String, Codable, CaseIterable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var iconName: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "sparkles"
        case .quizRush: return "questionmark.bubble.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .purple
        }
    }
}

struct GameRecord: Codable, Identifiable {
    var id: UUID = UUID()
    let gameType: GameType
    let score: Int
    let detail: String
    let date: Date
    
    // Formatted date for UI display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
