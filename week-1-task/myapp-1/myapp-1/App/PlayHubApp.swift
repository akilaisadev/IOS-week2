//
//  PlayHubApp.swift
//  myapp-1
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
