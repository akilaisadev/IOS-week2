//
//  StatsTab.swift
//  myapp-1
//
//  tab view displaying game statistics and charts
//

import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var statsVM = StatsVM()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if statsVM.totalGames == 0 {
                            emptyStateView
                        } else {
                            summaryMetricsGrid
                            bestScoresChartView
                            totalPointsChartView
                            recentGamesView
                            modeBreakdownView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
        }
    }
    
    // view displayed when no games have been recorded yet
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("No Games Played Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Play a game in the Home tab to see your statistics and charts here!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.top, 20)
    }
    
    // 2x2 grid of top summary metrics
    private var summaryMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            metricCard(
                title: "Total Games",
                value: "\(statsVM.totalGames)",
                icon: "gamecontroller.fill",
                color: .blue
            )
            metricCard(
                title: "Total Points",
                value: "\(statsVM.totalPoints)",
                icon: "star.fill",
                color: .purple
            )
            metricCard(
                title: "Avg Score",
                value: "\(statsVM.averageScore)",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            metricCard(
                title: "Favorite Mode",
                value: statsVM.favoriteMode?.title ?? "None",
                icon: statsVM.favoriteMode?.iconName ?? "heart.fill",
                color: statsVM.favoriteMode?.color ?? .orange
            )
        }
    }
    
    // bar chart comparing personal best scores across game modes
    private var bestScoresChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Bests")
                .font(.headline)
            
            Chart {
                ForEach(GameMode.allCases) { mode in
                    BarMark(
                        x: .value("Mode", mode.title),
                        y: .value("Score", statsVM.bestScore(for: mode))
                    )
                    .foregroundStyle(mode.color)
                    .annotation(position: .top) {
                        Text("\(statsVM.bestScore(for: mode))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 180)
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // bar chart comparing total points accumulated per game mode
    private var totalPointsChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Points per Mode")
                .font(.headline)
            
            Chart {
                ForEach(GameMode.allCases) { mode in
                    BarMark(
                        x: .value("Mode", mode.title),
                        y: .value("Total Points", statsVM.totalScore(for: mode))
                    )
                    .foregroundStyle(mode.color.opacity(0.8))
                    .annotation(position: .top) {
                        Text("\(statsVM.totalScore(for: mode))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 180)
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // list of recently completed game sessions
    private var recentGamesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Games")
                .font(.headline)
            
            ForEach(statsVM.recentSessions) { session in
                HStack(spacing: 12) {
                    Image(systemName: session.mode.iconName)
                        .foregroundColor(session.mode.color)
                        .font(.title3)
                        .frame(width: 32, height: 32)
                        .background(session.mode.color.opacity(0.15))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.mode.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
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
                
                if session.id != statsVM.recentSessions.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // breakdown of games played and total scores per mode
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
                        Text("\(statsVM.gamesPlayed(for: mode)) games")
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
    
    // helper to create summary cards
    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    StatsTab()
}
