//
//  StatsTab.swift
//  myapp-1
//
//  tab view displaying comprehensive game statistics, time played metrics, and interactive charts
//

import SwiftUI
import Charts

enum ModeSelection: String, CaseIterable, Identifiable {
    case all = "All"
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { rawValue }
    
    var gameMode: GameMode? {
        switch self {
        case .all: return nil
        case .tapFrenzy: return .tapFrenzy
        case .lightItUp: return .lightItUp
        case .quizRush: return .quizRush
        }
    }
}

struct StatsTab: View {
    @StateObject private var statsVM = StatsVM()
    @State private var selectedMode: ModeSelection = .all
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        modePickerView
                        
                        if statsVM.totalGames == 0 {
                            emptyStateView
                        } else {
                            summaryMetricsGrid
                            chartsContainerView
                            recentGamesView
                            if selectedMode == .all {
                                modeBreakdownView
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var modePickerView: some View {
        Picker("Filter Mode", selection: $selectedMode) {
            ForEach(ModeSelection.allCases) { selection in
                Text(selection.rawValue).tag(selection)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 4)
    }
    
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
    
    private var summaryMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.Spacing.small), GridItem(.flexible(), spacing: AppTheme.Spacing.small)], spacing: AppTheme.Spacing.small) {
            if let mode = selectedMode.gameMode {
                AppStatCard(
                    title: "Games Played",
                    value: "\(statsVM.gamesPlayed(for: mode))",
                    icon: mode.iconName,
                    color: mode.color
                )
                AppStatCard(
                    title: "Total Points",
                    value: "\(statsVM.totalPoints(for: mode))",
                    icon: "star.fill",
                    color: .purple
                )
                AppStatCard(
                    title: "Personal Best",
                    value: "\(statsVM.bestScore(for: mode))",
                    icon: "trophy.fill",
                    color: .orange
                )
                AppStatCard(
                    title: "Avg Score",
                    value: "\(statsVM.averageScore(for: mode))",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                AppStatCard(
                    title: "Total Time",
                    value: statsVM.formattedTimePlayed(for: mode),
                    icon: "clock.fill",
                    color: .indigo
                )
                AppStatCard(
                    title: "Avg Duration",
                    value: statsVM.formattedAverageDuration(for: mode),
                    icon: "timer",
                    color: .cyan
                )
            } else {
                AppStatCard(
                    title: "Total Games",
                    value: "\(statsVM.totalGames)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
                AppStatCard(
                    title: "Total Points",
                    value: "\(statsVM.totalPoints)",
                    icon: "star.fill",
                    color: .purple
                )
                AppStatCard(
                    title: "Avg Score",
                    value: "\(statsVM.averageScore)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                AppStatCard(
                    title: "Favorite Mode",
                    value: statsVM.favoriteMode?.title ?? "None",
                    icon: statsVM.favoriteMode?.iconName ?? "heart.fill",
                    color: statsVM.favoriteMode?.color ?? .orange
                )
                AppStatCard(
                    title: "Time Played",
                    value: statsVM.formattedTimePlayed(for: nil),
                    icon: "clock.fill",
                    color: .indigo
                )
                AppStatCard(
                    title: "Avg Duration",
                    value: statsVM.formattedAverageDuration(for: nil),
                    icon: "timer",
                    color: .cyan
                )
            }
        }
    }
    
    @ViewBuilder
    private var chartsContainerView: some View {
        if let mode = selectedMode.gameMode {
            dedicatedModeChartView(for: mode)
            dedicatedModeTimeChartView(for: mode)
        } else {
            bestScoresChartView
            totalPointsChartView
            totalTimePlayedChartView
        }
    }
    
    private func dedicatedModeChartView(for mode: GameMode) -> some View {
        let history = statsVM.historySessions(for: mode)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(mode.title) Score Progression")
                        .font(.headline)
                    Text("Points scored across recent attempts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(mode.color)
            }
            
            if history.isEmpty {
                Text("No sessions recorded yet for \(mode.title)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 140)
            } else {
                Chart {
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, session in
                        BarMark(
                            x: .value("Attempt", "Game \(index + 1)"),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(mode.color)
                        .annotation(position: .top) {
                            Text("\(session.score)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 180)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func dedicatedModeTimeChartView(for mode: GameMode) -> some View {
        let history = statsVM.historySessions(for: mode)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(mode.title) Session Durations")
                        .font(.headline)
                    Text("Time played per recent attempt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "timer")
                    .foregroundColor(.cyan)
            }
            
            if history.isEmpty {
                Text("No sessions recorded yet for \(mode.title)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 140)
            } else {
                Chart {
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, session in
                        BarMark(
                            x: .value("Attempt", "Game \(index + 1)"),
                            y: .value("Seconds", session.timePlayedSeconds)
                        )
                        .foregroundStyle(Color.cyan.opacity(0.85))
                        .annotation(position: .top) {
                            Text(session.formattedDuration)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 180)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var bestScoresChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Personal Bests by Mode")
                        .font(.headline)
                    Text("Highest single-game score per mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "trophy.fill")
                    .foregroundColor(.orange)
            }
            
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
    
    private var totalPointsChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Points per Mode")
                        .font(.headline)
                    Text("Cumulative points across all sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.purple)
            }
            
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
    
    private var totalTimePlayedChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Time Played by Mode")
                        .font(.headline)
                    Text("Cumulative duration across all sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "clock.fill")
                    .foregroundColor(.indigo)
            }
            
            Chart {
                ForEach(GameMode.allCases) { mode in
                    BarMark(
                        x: .value("Mode", mode.title),
                        y: .value("Seconds", statsVM.totalTimePlayedSeconds(for: mode))
                    )
                    .foregroundStyle(mode.color.opacity(0.85))
                    .annotation(position: .top) {
                        Text(statsVM.formattedTimePlayed(for: mode))
                            .font(.caption2)
                            .fontWeight(.semibold)
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

#Preview {
    StatsTab()
}
