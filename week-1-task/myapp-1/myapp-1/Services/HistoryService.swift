//
//  HistoryService.swift
//  myapp-1
//
//  service responsible for saving game sessions to user defaults
//

import SwiftUI
import Combine

class HistoryService: ObservableObject {
    static let shared = HistoryService()
    
    private let sessionsKey = "GameHubSessions"
    private let oldStorageKey = "GameHubHistoryRecords"
    
    @Published private(set) var sessions: [GameSession] = []
    
    // compatibility alias for older views
    var records: [GameSession] { sessions }
    
    private init() {
        loadSessions()
    }
    
    // load sessions from local storage with migration
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey) {
            do {
                sessions = try JSONDecoder().decode([GameSession].self, from: data)
                return
            } catch {
                print("failed to decode sessions: \(error)")
            }
        }
        
        // check for legacy records and migrate
        if let oldData = UserDefaults.standard.data(forKey: oldStorageKey) {
            do {
                sessions = try JSONDecoder().decode([GameSession].self, from: oldData)
                saveSessions()
                UserDefaults.standard.removeObject(forKey: oldStorageKey)
                return
            } catch {
                print("failed to migrate legacy records: \(error)")
            }
        }
        
        sessions = []
    }
    
    // save sessions to local storage
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
        } catch {
            print("failed to save sessions: \(error)")
        }
    }
    
    // add session from older game views
    func addRecord(gameType: GameMode, score: Int, detail: String) {
        addSession(mode: gameType, score: score)
    }
    
    // add new completed game session with coordinates
    func addSession(mode: GameMode, score: Int, latitude: Double? = nil, longitude: Double? = nil) {
        let newSession = GameSession(
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        sessions.insert(newSession, at: 0)
        saveSessions()
    }
    
    // get sessions filtered by mode
    func getSessions(for mode: GameMode?) -> [GameSession] {
        guard let m = mode else { return sessions }
        return sessions.filter { $0.mode == m }
    }
    
    // compatibility helper for old views
    func getRecords(for gameType: GameMode?) -> [GameSession] {
        getSessions(for: gameType)
    }
    
    var totalCombinedScore: Int {
        sessions.reduce(0) { $0 + $1.score }
    }
    
    func clearHistory() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: sessionsKey)
        UserDefaults.standard.removeObject(forKey: oldStorageKey)
    }
}
