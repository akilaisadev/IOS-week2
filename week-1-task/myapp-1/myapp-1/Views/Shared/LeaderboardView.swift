//
//  LeaderboardView.swift
//  myapp-1
//
//  Arcade Trophy Room hub displaying overall combined scores and cross-game history.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject private var historyService = HistoryService.shared
    @ObservedObject private var walletService = WalletService.shared
    @AppStorage("tapFrenzyHighScore") private var tapHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightHighScore = 0
    @AppStorage("quizRushHighScore") private var quizHighScore = 0
    
    @State private var showingClearAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Text("LEVEL \(walletService.wallet.level)")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                        
                        Text("\(walletService.wallet.xp) Total XP")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.6), radius: 25, x: 0, y: 5)
                    
                    Text("TOTAL COMBINED SCORE")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                    
                    Text("\(historyService.totalCombinedScore)")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                VStack(alignment: .leading, spacing: 14) {
                    Text("GAME HIGH SCORES")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        highScoreRow(title: "Tap Frenzy", icon: "hand.tap.fill", color: .blue, score: tapHighScore)
                        highScoreRow(title: "Light It Up", icon: "sparkles", color: .orange, score: lightHighScore)
                        highScoreRow(title: "Quiz Rush", icon: "questionmark.bubble.fill", color: .purple, score: quizHighScore)
                    }
                    .padding(.horizontal)
                }
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("RECENT ACTIVITY LOG")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !historyService.records.isEmpty {
                            Button("Clear History") {
                                showingClearAlert = true
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    if historyService.records.isEmpty {
                        Text("No gameplay logs recorded yet. Jump into a game!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(historyService.records) { record in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(record.gameType.color.opacity(0.18))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: record.gameType.iconName)
                                            .foregroundColor(record.gameType.color)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(record.gameType.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        Text(record.detail)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("+\(record.score)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(record.gameType.color)
                                        Text(record.formattedDate)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90)
        }
        .navigationTitle("Trophy Room")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(AppTheme.Colors.secondaryBackground.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Clear All History?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                historyService.clearHistory()
            }
        } message: {
            Text("This will delete all saved session logs from local storage.")
        }
    }
    private func highScoreRow(title: String, icon: String, color: Color, score: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 36)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text("\(score) PTS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
