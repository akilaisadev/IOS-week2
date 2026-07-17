//
//  HistoryService.swift
//  myapp-1
//

import SwiftUI
import Combine

class HistoryService: ObservableObject {
    static let shared = HistoryService()
    
    private let sessionsKey = "GameHubSessions"
    private let oldStorageKey = "GameHubHistoryRecords"
    
    @Published private(set) var sessions: [GameSession] = []
    
    var records: [GameSession] { sessions }
    
    private init() {
        loadSessions()
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey) {
            do {
                sessions = try JSONDecoder().decode([GameSession].self, from: data)
                return
            } catch {
                print("failed to decode sessions: \(error)")
            }
        }
        
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
    
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
        } catch {
            print("failed to save sessions: \(error)")
        }
    }
    
    func addRecord(gameType: GameMode, score: Int, detail: String, duration: TimeInterval? = nil) {
        addSession(mode: gameType, score: score, duration: duration)
    }
    
    func addSession(mode: GameMode, score: Int, latitude: Double? = nil, longitude: Double? = nil, duration: TimeInterval? = nil) {
        let newSession = GameSession(
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude,
            duration: duration
        )
        sessions.insert(newSession, at: 0)
        saveSessions()
    }
    
    func getSessions(for mode: GameMode?) -> [GameSession] {
        guard let m = mode else { return sessions }
        return sessions.filter { $0.mode == m }
    }
    
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
