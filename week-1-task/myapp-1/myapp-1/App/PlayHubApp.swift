//
//  PlayHubApp.swift
//  myapp-1
//
//  main app entry point for coursework
//

import SwiftUI

@main
struct PlayHubApp: App {
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var walletService = WalletService.shared
    @StateObject private var marketplaceService = MarketplaceService.shared
    @StateObject private var streakService = StreakService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
