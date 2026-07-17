//
//  StatsChartsSection.swift
//  myapp-1
//
//  Component responsible for displaying SwiftUI interactive bar charts across game modes and sessions.
//

import SwiftUI
import Charts

struct StatsChartsSection: View {
    @ObservedObject var statsVM: StatsVM
    var selectedMode: ModeSelection
    
    var body: some View {
        VStack(spacing: 20) {
            if let mode = selectedMode.gameMode {
                dedicatedModeChartView(for: mode)
                dedicatedModeTimeChartView(for: mode)
            } else {
                bestScoresChartView
                totalPointsChartView
                totalTimePlayedChartView
            }
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
}
