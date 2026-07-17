//
//  GameSession.swift
//  myapp-1
//

import Foundation
import CoreLocation

struct GameSession: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let mode: GameMode
    let score: Int
    let timestamp: Date
    var latitude: Double? = nil
    var longitude: Double? = nil
    var duration: TimeInterval? = nil
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var timePlayedSeconds: Int {
        if let dur = duration {
            return max(1, Int(dur))
        }
        // falback if time is missing
        switch mode {
        case .tapFrenzy:
            return 30 + max(0, score / 10 * 3)
        case .lightItUp:
            return 45 + max(0, score * 2)
        case .quizRush:
            return 50 + max(0, score / 2)
        }
    }
    
    var formattedDuration: String {
        let seconds = timePlayedSeconds
        let minutes = seconds / 60
        let remSeconds = seconds % 60
        if minutes > 0 {
            return "\(minutes)m \(remSeconds)s"
        } else {
            return "\(remSeconds)s"
        }
    }
    
    var hasValidLocation: Bool {
        latitude != nil && longitude != nil
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var gameType: GameMode { mode }
    var date: Date { timestamp }
    var detail: String { "Score: \(score)" }
}

typealias GameRecord = GameSession
