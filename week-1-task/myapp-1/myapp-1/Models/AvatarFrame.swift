//
//  AvatarFrame.swift
//  myapp-1
//

import SwiftUI

enum AvatarFrameStyle: String, Codable, CaseIterable, Identifiable {
    case defaultFrame = "Default"
    case goldFrame = "Gold VIP"
    case neonFrame = "Neon Cyber"
    case galaxyFrame = "Galaxy Star"
    
    var id: String { rawValue }
    
    var gradientColors: [Color] {
        switch self {
        case .defaultFrame: return [.blue, .purple]
        case .goldFrame: return [.yellow, .orange]
        case .neonFrame: return [.cyan, .green]
        case .galaxyFrame: return [.purple, .pink]
        }
    }
    
    var itemID: String? {
        switch self {
        case .defaultFrame: return nil
        case .goldFrame: return "frame_gold"
        case .neonFrame: return "frame_neon"
        case .galaxyFrame: return "frame_galaxy"
        }
    }
}
