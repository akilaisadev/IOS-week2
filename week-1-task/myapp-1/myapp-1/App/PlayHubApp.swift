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
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
