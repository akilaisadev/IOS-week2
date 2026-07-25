//
//  HighScoreView.swift
//  myapp-1
//
//  Displays the stored high score with a trophy icon badge.
//

import SwiftUI

struct HighScoreView: View {
    let highScore: Int
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.extraSmall) {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("HIGH SCORE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text("\(highScore)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.small)
        .padding(.vertical, AppTheme.Spacing.extraSmall)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.15))
        )
    }
}

#Preview {
    HighScoreView(highScore: 250)
        .padding()
}
