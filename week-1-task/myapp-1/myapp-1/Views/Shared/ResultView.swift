//
//  ResultView.swift
//  myapp-1
//
//  post-game result screen with two-stage flow preventing accidental button taps
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let mode: GameMode
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    var onViewHistory: (() -> Void)? = nil
    
    @State private var showingActions = false
    @State private var canInteract = false
    @AppStorage("playerName") private var playerName = "Player 1"
    @ObservedObject private var achievementService = AchievementService.shared
    
    var isNewBest: Bool {
        score >= highScore && score > 0
    }
    
    var shareText: String {
        let namePrefix = (playerName == "Player 1" || playerName.isEmpty) ? "I" : playerName
        if isNewBest {
            return "\(namePrefix) just achieved a new personal best of \(score) points in \(mode.title) on PlayHub! Can you beat my score?"
        } else {
            return "\(namePrefix) just scored \(score) points in \(mode.title) on PlayHub! Can you beat my score?"
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                if let ach = achievementService.recentlyUnlocked {
                    AchievementToastView(achievement: ach) {
                        achievementService.dismissToast()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 10)
                }
                
                ZStack {
                    if !showingActions {
                        scoreScreen
                            .transition(.opacity)
                    } else {
                        actionsScreen
                            .transition(.opacity)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 28)
                .frame(maxWidth: 400)
                .animation(.easeInOut(duration: 0.22), value: showingActions)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                canInteract = true
            }
        }
    }
    
    private var scoreScreen: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: isNewBest ? "trophy.fill" : "flag.checkered")
                    .font(.system(size: 40))
                    .foregroundColor(isNewBest ? .yellow : mode.color)
                    .shadow(color: (isNewBest ? Color.yellow : mode.color).opacity(0.3), radius: 6, x: 0, y: 3)
                
                Text(isNewBest ? "New Personal Best!" : "Game Completed")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            ScoreBadge(score: score, highScore: highScore, mode: mode)
            
            Button {
                guard canInteract else { return }
                showingActions = true
            } label: {
                HStack {
                    Text("Next: Options & Share")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(canInteract ? mode.color : mode.color.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: mode.color.opacity(canInteract ? 0.3 : 0.0), radius: 6, x: 0, y: 3)
            }
            .disabled(!canInteract)
        }
    }
    
    private var actionsScreen: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    showingActions = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Score")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(mode.color)
                }
                
                Spacer()
                
                Text("Game Actions")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Score")
                }
                .font(.subheadline)
                .opacity(0)
            }
            .padding(.bottom, 2)
            
            HStack {
                Text("Final Score: \(score)")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("\(highScore)")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            VStack(spacing: 10) {
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
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                PrimaryButton(
                    title: "Play Again",
                    iconName: "arrow.counterclockwise",
                    backgroundColor: mode.color,
                    action: onPlayAgain
                )
                
                if let onViewHistory = onViewHistory {
                    Button(action: onViewHistory) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("View Game History")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(mode.color)
                        .padding(.vertical, 6)
                    }
                }
                
                Button(action: onHome) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Return Home")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
                }
            }
        }
    }
}

#Preview {
    ResultView(score: 150, highScore: 120, mode: .tapFrenzy, onPlayAgain: {}, onHome: {})
}
