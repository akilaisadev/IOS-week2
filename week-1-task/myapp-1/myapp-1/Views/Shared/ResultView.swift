//
//  ResultView.swift
//  myapp-1
//
//  post-game result screen displaying final score, personal best celebration, and ShareLink
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let mode: GameMode
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    var onViewHistory: (() -> Void)? = nil
    
    var isNewBest: Bool {
        score >= highScore && score > 0
    }
    
    var shareText: String {
        if isNewBest {
            return "I just achieved a new personal best of \(score) points in \(mode.title) on PlayHub! Can you beat my score?"
        } else {
            return "I just scored \(score) points in \(mode.title) on PlayHub! Can you beat my score?"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // header icon and celebratory title
            VStack(spacing: 8) {
                Image(systemName: isNewBest ? "trophy.fill" : "flag.checkered")
                    .font(.system(size: 52))
                    .foregroundColor(isNewBest ? .yellow : mode.color)
                    .shadow(color: (isNewBest ? Color.yellow : mode.color).opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text(isNewBest ? "New Personal Best!" : "Game Completed")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            // score badge module
            ScoreBadge(score: score, highScore: highScore, mode: mode)
            
            // action buttons container including native ShareLink
            VStack(spacing: 12) {
                // native share button
                ShareLink(
                    item: shareText,
                    subject: Text("\(mode.title) Score: \(score) pts"),
                    message: Text(shareText)
                ) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Final Score")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: Color.orange.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                
                // play again primary button
                PrimaryButton(
                    title: "Play Again",
                    iconName: "arrow.counterclockwise",
                    backgroundColor: mode.color,
                    action: onPlayAgain
                )
                
                // view history secondary action
                if let onViewHistory = onViewHistory {
                    Button(action: onViewHistory) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("View Game History")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(mode.color)
                        .padding(.vertical, 8)
                    }
                }
                
                // return home action
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
                .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 12)
        )
        .padding(24)
    }
}

#Preview {
    ResultView(score: 150, highScore: 120, mode: .tapFrenzy, onPlayAgain: {}, onHome: {})
}
