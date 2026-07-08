//
//  StatsVM.swift
//  myapp-1
//
//  view model calculating score aggregates and personal bests
//

import SwiftUI
import Combine

class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // bind to history service so stats update automatically when new games are played
        HistoryService.shared.$sessions
            .receive(on: RunLoop.main)
            .sink { [weak self] newSessions in
                self?.sessions = newSessions
            }
            .store(in: &cancellables)
    }
    
    // total points across all modes
    var totalPoints: Int {
        sessions.reduce(0) { $0 + $1.score }
    }
    
    // total number of games played
    var totalGames: Int {
        sessions.count
    }
    
    // average score across all modes
    var averageScore: Int {
        totalGames > 0 ? totalPoints / totalGames : 0
    }
    
    // most played game mode
    var favoriteMode: GameMode? {
        GameMode.allCases.max(by: { gamesPlayed(for: $0) < gamesPlayed(for: $1) })
    }
    
    // most recent game sessions across all modes (up to 5)
    var recentSessions: [GameSession] {
        Array(sessions.suffix(5).reversed())
    }
    
    // personal best for specific mode
    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }
    
    // total points accumulated in a specific mode
    func totalScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.score }
    }
    
    // count of games played in a specific mode
    func gamesPlayed(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }
    
    // MARK: - Filtered Helper Methods for Dedicated Mode Tabs
    
    // filtered sessions by optional mode
    func filteredSessions(for mode: GameMode?) -> [GameSession] {
        guard let mode = mode else { return sessions }
        return sessions.filter { $0.mode == mode }
    }
    
    // total points for optional mode
    func totalPoints(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).reduce(0) { $0 + $1.score }
    }
    
    // total games played for optional mode
    func gamesPlayed(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).count
    }
    
    // average score for optional mode
    func averageScore(for mode: GameMode?) -> Int {
        let count = gamesPlayed(for: mode)
        return count > 0 ? totalPoints(for: mode) / count : 0
    }
    
    // best score for optional mode
    func bestScore(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).map { $0.score }.max() ?? 0
    }
    
    // recent sessions for optional mode (up to 5)
    func recentSessions(for mode: GameMode?) -> [GameSession] {
        Array(filteredSessions(for: mode).suffix(5).reversed())
    }
    
    // recent session history (chronological order up to 10 for bar chart progression)
    func historySessions(for mode: GameMode) -> [GameSession] {
        Array(sessions.filter { $0.mode == mode }.suffix(10))
    }
    
    // total time played across all sessions in seconds for optional mode
    func totalTimePlayedSeconds(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).reduce(0) { $0 + $1.timePlayedSeconds }
    }
    
    // total time played across sessions for a specific non-optional game mode
    func totalTimePlayedSeconds(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.timePlayedSeconds }
    }
    
    // total time played formatted string (e.g., "12m 30s")
    func formattedTimePlayed(for mode: GameMode?) -> String {
        let total = totalTimePlayedSeconds(for: mode)
        let minutes = total / 60
        let seconds = total % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // average duration per game for optional mode
    func formattedAverageDuration(for mode: GameMode?) -> String {
        let count = gamesPlayed(for: mode)
        guard count > 0 else { return "0s" }
        let avgSeconds = totalTimePlayedSeconds(for: mode) / count
        let minutes = avgSeconds / 60
        let seconds = avgSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
