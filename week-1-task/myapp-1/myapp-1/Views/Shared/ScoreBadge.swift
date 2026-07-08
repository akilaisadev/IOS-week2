//
//  ScoreBadge.swift
//  myapp-1
//
//  reusable score display badge with celebratory styling
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
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: isNewBest ? "crown.fill" : "star.fill")
                    .foregroundColor(isNewBest ? .yellow : mode.color)
                Text(isNewBest ? "NEW PERSONAL BEST!" : "FINAL SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isNewBest ? .orange : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(isNewBest ? Color.yellow.opacity(0.15) : Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            Text("\(score)")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: mode.color.opacity(0.2), radius: 6, x: 0, y: 3)
            
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.subheadline)
                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
}

#Preview {
    ScoreBadge(score: 150, highScore: 120, mode: .tapFrenzy)
}
