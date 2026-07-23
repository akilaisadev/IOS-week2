//
//  WalletService.swift
//  myapp-1
//

import SwiftUI
import Combine

class WalletService: ObservableObject {
    static let shared = WalletService()
    
    private let walletKey = "PlayerWalletData"
    @Published private(set) var wallet: PlayerWallet
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: walletKey),
           let decoded = try? JSONDecoder().decode(PlayerWallet.self, from: data) {
            self.wallet = decoded
        } else {
            let code = WalletService.generateRandomCode()
            self.wallet = PlayerWallet(coins: 100, xp: 0, level: 1, referralCode: code)
            save()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(wallet) {
            UserDefaults.standard.set(encoded, forKey: walletKey)
        }
    }
    
    func addCoins(_ amount: Int) {
        wallet.coins += amount
        save()
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if wallet.isDeveloperMode { return true }
        guard wallet.coins >= amount else { return false }
        wallet.coins -= amount
        save()
        return true
    }
    
    // Calculates level ups when accumulated XP crosses threshold
    func addXP(_ amount: Int) {
        wallet.xp += amount
        while wallet.xp >= wallet.xpForNextLevel {
            wallet.level += 1
            wallet.coins += 50
        }
        save()
    }
    
    func earnCoins(from score: Int) {
        let earned = max(1, score / 10)
        addCoins(earned)
    }
    
    func toggleDeveloperMode() {
        wallet.isDeveloperMode.toggle()
        save()
    }
    
    func grantDevCoins() {
        wallet.coins += 10000
        save()
    }
    
    private static func generateRandomCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
