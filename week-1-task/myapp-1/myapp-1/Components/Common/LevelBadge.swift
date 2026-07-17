//
//  LevelBadge.swift
//  myapp-1
//
//  Displays the current game difficulty level or status badge.
//

import SwiftUI

struct LevelBadge: View {
    let levelText: String
    var badgeColor: Color = .purple
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
            Text(levelText)
                .fontWeight(.bold)
        }
        .font(.subheadline)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(badgeColor.opacity(0.18))
        .foregroundColor(badgeColor)
        .clipShape(Capsule())
    }
}

#Preview {
    LevelBadge(levelText: "Level 2: Speed Up", badgeColor: .blue)
        .padding()
}
