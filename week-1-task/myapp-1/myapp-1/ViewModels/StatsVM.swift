//
//  StatsVM.swift
//  myapp-1
//
//  view model calculating score aggregates and personal bests
//

import SwiftUI
import Combine

class StatsVM: ObservableObject {
    @Published var records: [GameRecord] = []
    
    init() {
        loadRecords()
    }
    
    // load saved records from storage
    func loadRecords() {
        records = HistoryService.shared.records
    }
    
    // total points across all modes
    var totalPoints: Int {
        records.reduce(0) { $0 + $1.score }
    }
    
    // personal best for specific mode
    func bestScore(for type: GameType) -> Int {
        records.filter { $0.gameType == type }.map { $0.score }.max() ?? 0
    }
}
