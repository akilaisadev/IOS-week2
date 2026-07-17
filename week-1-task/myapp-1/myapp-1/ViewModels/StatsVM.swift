//
//  StatsVM.swift
//  myapp-1
//

import SwiftUI
import Combine

class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        HistoryService.shared.$sessions
            .receive(on: RunLoop.main)
            .sink { [weak self] newSessions in
                self?.sessions = newSessions
            }
            .store(in: &cancellables)
    }
    
    var totalPoints: Int {
        sessions.reduce(0) { $0 + $1.score }
    }
    
    var totalGames: Int {
        sessions.count
    }
    
    var averageScore: Int {
        totalGames > 0 ? totalPoints / totalGames : 0
    }
    
    var favoriteMode: GameMode? {
        GameMode.allCases.max(by: { gamesPlayed(for: $0) < gamesPlayed(for: $1) })
    }
    
    var recentSessions: [GameSession] {
        Array(sessions.suffix(5).reversed())
    }
    
    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }
    
    func totalScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.score }
    }
    
    func gamesPlayed(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }
    
    func filteredSessions(for mode: GameMode?) -> [GameSession] {
        guard let mode = mode else { return sessions }
        return sessions.filter { $0.mode == mode }
    }
    
    func totalPoints(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).reduce(0) { $0 + $1.score }
    }
    
    func gamesPlayed(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).count
    }
    
    func averageScore(for mode: GameMode?) -> Int {
        let count = gamesPlayed(for: mode)
        return count > 0 ? totalPoints(for: mode) / count : 0
    }
    
    func bestScore(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).map { $0.score }.max() ?? 0
    }
    
    func recentSessions(for mode: GameMode?) -> [GameSession] {
        Array(filteredSessions(for: mode).suffix(5).reversed())
    }
    
    func historySessions(for mode: GameMode) -> [GameSession] {
        Array(sessions.filter { $0.mode == mode }.suffix(10))
    }
    
    func totalTimePlayedSeconds(for mode: GameMode?) -> Int {
        filteredSessions(for: mode).reduce(0) { $0 + $1.timePlayedSeconds }
    }
    
    func totalTimePlayedSeconds(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.timePlayedSeconds }
    }
    
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
