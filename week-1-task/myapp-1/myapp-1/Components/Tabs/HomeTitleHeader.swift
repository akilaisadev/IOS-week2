//
//  HomeTitleHeader.swift
//  myapp-1
//
//  Houses the hero title banner and the Trophy Room / Leaderboard card for the Home tab.
//

import SwiftUI

struct HomeTitleHeader: View {
    var playerName: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("GameHub")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
            
            Text(playerName == "Player 1" || playerName.isEmpty ? "iOS Mini-Game Collection" : "Welcome back, \(playerName)!")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
}

struct TrophyRoomCard: View {
    @ObservedObject var historyService = HistoryService.shared
    
    var body: some View {
        NavigationLink(destination: LeaderboardView()) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.25))
                        .frame(width: 58, height: 58)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trophy Room")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Total Combined Score: \(historyService.totalCombinedScore) PTS")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.yellow.opacity(0.2), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}
