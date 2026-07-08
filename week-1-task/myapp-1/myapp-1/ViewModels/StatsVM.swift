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
    
    init() {
        loadSessions()
    }
    
    // load saved sessions from storage
    func loadSessions() {
        // will read from storage in phase 5
    }
    
    // total points across all modes
    var totalPoints: Int {
        sessions.reduce(0) { $0 + $1.score }
    }
    
    // personal best for specific mode
    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }
}
