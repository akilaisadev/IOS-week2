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
}
