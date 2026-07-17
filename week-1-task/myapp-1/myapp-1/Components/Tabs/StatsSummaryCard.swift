//
//  StatsSummaryCard.swift
//  myapp-1
//

import SwiftUI

struct StatsSummaryCard: View {
    @ObservedObject var statsVM: StatsVM
    var selectedMode: ModeSelection
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            if let mode = selectedMode.gameMode {
                metricCard(
                    title: "Games Played",
                    value: "\(statsVM.gamesPlayed(for: mode))",
                    icon: mode.iconName,
                    color: mode.color
                )
                metricCard(
                    title: "Total Points",
                    value: "\(statsVM.totalPoints(for: mode))",
                    icon: "star.fill",
                    color: .purple
                )
                metricCard(
                    title: "Personal Best",
                    value: "\(statsVM.bestScore(for: mode))",
                    icon: "trophy.fill",
                    color: .orange
                )
                metricCard(
                    title: "Avg Score",
                    value: "\(statsVM.averageScore(for: mode))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                metricCard(
                    title: "Total Time",
                    value: statsVM.formattedTimePlayed(for: mode),
                    icon: "clock.fill",
                    color: .indigo
                )
                metricCard(
                    title: "Avg Duration",
                    value: statsVM.formattedAverageDuration(for: mode),
                    icon: "timer",
                    color: .cyan
                )
            } else {
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
                metricCard(
                    title: "Time Played",
                    value: statsVM.formattedTimePlayed(for: nil),
                    icon: "clock.fill",
                    color: .indigo
                )
                metricCard(
                    title: "Avg Duration",
                    value: statsVM.formattedAverageDuration(for: nil),
                    icon: "timer",
                    color: .cyan
                )
            }
        }
    }
    
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
