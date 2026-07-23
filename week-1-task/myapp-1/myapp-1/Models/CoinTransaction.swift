//
//  CoinTransaction.swift
//  myapp-1
//

import Foundation

struct CoinTransaction: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let amount: Int
    let reason: String
    let timestamp: Date
    
    var isPositive: Bool { amount >= 0 }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
