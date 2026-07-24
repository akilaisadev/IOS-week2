//
//  ScoreView.swift
//  myapp-1
//
//  Displays the current game score and an optional multiplier badge.
//

import SwiftUI

struct ScoreView: View {
    let score: Int
    var multiplier: Int = 1
    var streak: Int? = nil
    
    var body: some View {
        AppCard {
            HStack(spacing: AppTheme.Spacing.small) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Text("\(score)")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                Spacer()
                
                if multiplier > 1 {
                    AppChip(text: "\(multiplier)x COMBO", icon: "flame.fill", color: AppTheme.Colors.secondary)
                }
                
                if let streak = streak, streak > 0 {
                    AppChip(text: "\(streak) STREAK", icon: "bolt.fill", color: AppTheme.Colors.primary)
                }
            }
        }
    }
}

#Preview {
    VStack {
        ScoreView(score: 120, multiplier: 3)
        ScoreView(score: 45, streak: 5)
    }
    .padding()
}
