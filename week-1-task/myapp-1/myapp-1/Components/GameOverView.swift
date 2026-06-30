//
//  GameOverView.swift
//  myapp-1
//
//  A reusable game over summary card displaying scores and navigation actions.
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    var onViewHistory: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("FINAL SCORE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text("\(score)")
                        .font(.system(size: 54, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("High Score:")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(highScore)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            
            VStack(spacing: 12) {
                PrimaryButton(title: "Play Again", iconName: "arrow.counterclockwise", backgroundColor: .blue, action: onPlayAgain)
                
                if let onViewHistory = onViewHistory {
                    Button(action: onViewHistory) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("View Game History")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                    }
                }
                
                Button(action: onHome) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Return Home")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .padding(24)
    }
}

#Preview {
    GameOverView(score: 85, highScore: 120, onPlayAgain: {}, onHome: {})
}
