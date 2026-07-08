//
//  GameSession.swift
//  myapp-1
//
//  model for a completed game session with coordinates
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
    
    // formatted date string for UI display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // helper to check if valid coordinates exist
    var hasValidLocation: Bool {
        latitude != nil && longitude != nil
    }
    
    // computed 2D coordinate for MapKit integration
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // compatibility properties for older views
    var gameType: GameMode { mode }
    var date: Date { timestamp }
    var detail: String { "Score: \(score)" }
}

// backward compatibility alias
typealias GameRecord = GameSession
