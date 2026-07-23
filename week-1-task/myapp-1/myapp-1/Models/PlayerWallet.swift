//
//  PlayerWallet.swift
//  myapp-1
//

import Foundation

struct PlayerWallet: Codable, Equatable {
    var coins: Int = 100
    var xp: Int = 0
    var level: Int = 1
    var referralCode: String = ""
    var referralsCompleted: Int = 0
    var isDeveloperMode: Bool = false
    
    var xpForNextLevel: Int {
        level * 100
    }
}
