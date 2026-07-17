//
//  PlayHubApp.swift
//  myapp-1
//

import SwiftUI

@main
struct PlayHubApp: App {
    // inject notification global obj
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
