//
//  WalletService.swift
//  myapp-1
//

import SwiftUI
import Combine

class WalletService: ObservableObject {
    static let shared = WalletService()
    
    private let walletKey = "PlayerWalletData"
    private let txKey = "PlayerWalletTransactionsData"
    @Published private(set) var wallet: PlayerWallet
    @Published private(set) var transactions: [CoinTransaction] = []
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: walletKey),
           let decoded = try? JSONDecoder().decode(PlayerWallet.self, from: data) {
            self.wallet = decoded
        } else {
            let code = WalletService.generateRandomCode()
            self.wallet = PlayerWallet(coins: 100, xp: 0, level: 1, referralCode: code)
            save()
        }
        loadTransactions()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(wallet) {
            UserDefaults.standard.set(encoded, forKey: walletKey)
        }
    }
    
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: txKey),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: data) {
            transactions = decoded
        }
    }
    
    private func logTransaction(amount: Int, reason: String) {
        let tx = CoinTransaction(amount: amount, reason: reason, timestamp: Date())
        transactions.insert(tx, at: 0)
        if transactions.count > 50 { transactions.removeLast() }
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: txKey)
        }
    }
    
    func addCoins(_ amount: Int, reason: String = "Earned Reward") {
        wallet.coins += amount
        logTransaction(amount: amount, reason: reason)
        save()
    }
    
    func spendCoins(_ amount: Int, reason: String = "Marketplace Purchase") -> Bool {
        if wallet.isDeveloperMode {
            logTransaction(amount: 0, reason: "\(reason) (Dev Free)")
            return true
        }
        guard wallet.coins >= amount else { return false }
        wallet.coins -= amount
        logTransaction(amount: -amount, reason: reason)
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
