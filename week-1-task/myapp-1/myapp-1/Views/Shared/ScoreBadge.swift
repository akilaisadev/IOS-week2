//
//  ScoreBadge.swift
//  myapp-1
//

import SwiftUI

struct ScoreBadge: View {
    let score: Int
    let highScore: Int
    let mode: GameMode
    
    var isNewBest: Bool {
        score >= highScore && score > 0
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: isNewBest ? "crown.fill" : "star.fill")
                    .foregroundColor(isNewBest ? .yellow : mode.color)
                Text(isNewBest ? "NEW PERSONAL BEST!" : "FINAL SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isNewBest ? .orange : .secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isNewBest ? Color.yellow.opacity(0.15) : Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            Text("\(score)")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: mode.color.opacity(0.2), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.subheadline)
                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ScoreBadge(score: 150, highScore: 120, mode: .tapFrenzy)
}
