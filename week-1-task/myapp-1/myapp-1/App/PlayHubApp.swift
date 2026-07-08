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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
