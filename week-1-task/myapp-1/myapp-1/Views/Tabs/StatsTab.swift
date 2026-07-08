//
//  StatsTab.swift
//  myapp-1
//
//  tab view displaying game statistics and charts
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
        }
    }
    
    // mode selection picker at top of screen
    private var modePickerView: some View {
        Picker("Filter Mode", selection: $selectedMode) {
            ForEach(ModeSelection.allCases) { selection in
                Text(selection.rawValue).tag(selection)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 4)
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
    
    // dynamic summary metrics grid adapting to selected game mode
    private var summaryMetricsGrid: some View {
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
            }
        }
    }
    
    // container switching between overview charts and dedicated mode session charts
    @ViewBuilder
    private var chartsContainerView: some View {
        if let mode = selectedMode.gameMode {
            dedicatedModeChartView(for: mode)
        } else {
            bestScoresChartView
            totalPointsChartView
        }
    }
    
    // dedicated bar chart showing recent attempt progression for a specific game mode
    private func dedicatedModeChartView(for mode: GameMode) -> some View {
        let history = statsVM.historySessions(for: mode)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("\(mode.title) Score Progression")
                .font(.headline)
            
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
    
    // bar chart comparing personal best scores across game modes
    private var bestScoresChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Bests by Mode")
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
    
    // list of recently completed game sessions filtered by mode
    private var recentGamesView: some View {
        let sessions = statsVM.recentSessions(for: selectedMode.gameMode)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(selectedMode == .all ? "Recent Games (All)" : "Recent Games (\(selectedMode.rawValue))")
                .font(.headline)
            
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
