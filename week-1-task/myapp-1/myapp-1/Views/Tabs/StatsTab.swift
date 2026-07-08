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
                            summaryMetricsView
                            bestScoresChartView
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
    
    // top summary cards for total games and points
    private var summaryMetricsView: some View {
        HStack(spacing: 16) {
            metricCard(title: "Total Games", value: "\(statsVM.totalGames)", icon: "gamecontroller.fill", color: .blue)
            metricCard(title: "Total Points", value: "\(statsVM.totalPoints)", icon: "star.fill", color: .purple)
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
            .frame(height: 200)
            .padding(.vertical, 8)
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
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
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
