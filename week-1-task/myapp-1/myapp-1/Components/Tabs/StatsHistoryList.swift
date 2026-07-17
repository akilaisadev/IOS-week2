//
//  StatsHistoryList.swift
//  myapp-1
//
//  Component responsible for displaying the recent game history list and per-mode statistical breakdowns.
//

import SwiftUI

struct StatsHistoryList: View {
    @ObservedObject var statsVM: StatsVM
    var selectedMode: ModeSelection
    
    var body: some View {
        VStack(spacing: 20) {
            recentGamesView
            if selectedMode == .all {
                modeBreakdownView
            }
        }
    }
    
    private var recentGamesView: some View {
        let sessions = statsVM.recentSessions(for: selectedMode.gameMode)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedMode == .all ? "Recent Games (All)" : "Recent Games (\(selectedMode.rawValue))")
                    .font(.headline)
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.secondary)
            }
            
            if sessions.isEmpty {
                Text("No sessions recorded yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(sessions) { session in
                    HStack(spacing: 12) {
                        Image(systemName: session.mode.iconName)
                            .foregroundColor(session.mode.color)
                            .font(.title3)
                            .frame(width: 32, height: 32)
                            .background(session.mode.color.opacity(0.15))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(session.mode.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("• \(session.formattedDuration)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.indigo)
                            }
                            
                            Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(session.score) pts")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                    
                    if session.id != sessions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var modeBreakdownView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mode Breakdown")
                .font(.headline)
            
            ForEach(GameMode.allCases) { mode in
                HStack {
                    Image(systemName: mode.iconName)
                        .foregroundColor(mode.color)
                        .frame(width: 24)
                    
                    Text(mode.title)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(statsVM.gamesPlayed(for: mode)) games • \(statsVM.formattedTimePlayed(for: mode))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(statsVM.totalScore(for: mode)) pts total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
                
                if mode != GameMode.allCases.last {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
