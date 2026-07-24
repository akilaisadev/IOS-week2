//
//  GameMode.swift
//  myapp-1
//
//  enum representing our 3 coursework game modes
//

import SwiftUI

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
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

typealias GameType = GameMode
