//
//  HistoryService.swift
//  myapp-1
//
//  Service responsible for persisting game history logs using UserDefaults local storage.
//

import SwiftUI
import Combine

class HistoryService: ObservableObject {
    static let shared = HistoryService()
    
    private let storageKey = "GameHubHistoryRecords"
    
    @Published private(set) var records: [GameRecord] = []
    
    private init() {
        loadRecords()
    }
    
    // Loads records from local storage
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            records = []
            return
        }
        
        do {
            records = try JSONDecoder().decode([GameRecord].self, from: data)
        } catch {
            print("Failed to decode game records: \(error)")
            records = []
        }
    }
    
    // Saves current records array to local storage
    private func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode game records: \(error)")
        }
    }
    
    // Adds a new completed game record and persists it immediately
    func addRecord(gameType: GameType, score: Int, detail: String) {
        let newRecord = GameRecord(
            gameType: gameType,
            score: score,
            detail: detail,
            date: Date()
        )
        // Insert at beginning so newest games appear first
        records.insert(newRecord, at: 0)
        saveRecords()
    }
    
    // Retrieves records filtered by game type
    func getRecords(for gameType: GameType?) -> [GameRecord] {
        guard let type = gameType else {
            return records
        }
        return records.filter { $0.gameType == type }
    }
    
    // Returns total combined score across all games
    var totalCombinedScore: Int {
        records.reduce(0) { $0 + $1.score }
    }
    
    // Clears all history from local storage
    func clearHistory() {
        records.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
