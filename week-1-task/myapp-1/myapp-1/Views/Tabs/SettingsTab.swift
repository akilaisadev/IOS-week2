//
//  SettingsTab.swift
//  myapp-1
//
//  tab view for application settings and preferences
//

import SwiftUI

struct SettingsTab: View {
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var soundManager = SoundManager.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                Form {
                    notificationsSection
                    audioSection
                    dataSection
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset All Statistics?", isPresented: $showingResetAlert) {
                Button("Reset All", role: .destructive) {
                    withAnimation {
                        HistoryService.shared.clearHistory()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action will permanently delete all recorded game sessions, scores, and map locations. This cannot be undone.")
            }
        }
    }
    
    // section managing local daily challenge reminders
    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $notificationService.isEnabled) {
                Label("Daily Reminders", systemImage: "bell.fill")
            }
            .tint(.blue)
            .onChange(of: notificationService.isEnabled) { _ in
                if notificationService.isEnabled {
                    notificationService.scheduleDailyChallenge(at: notificationService.reminderTime)
                } else {
                    notificationService.cancelDailyChallenge()
                }
            }
            
            if notificationService.isEnabled {
                DatePicker(
                    selection: $notificationService.reminderTime,
                    displayedComponents: .hourAndMinute
                ) {
                    Label("Reminder Time", systemImage: "clock.fill")
                }
                .onChange(of: notificationService.reminderTime) { _ in
                    if notificationService.isEnabled {
                        notificationService.scheduleDailyChallenge(at: notificationService.reminderTime)
                    }
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Receive a daily reminder to play your favorite game mode and beat your personal best.")
        }
    }
    
    // section controlling audio and haptic feedback
    private var audioSection: some View {
        Section {
            Toggle(isOn: $soundManager.isMuted) {
                Label("Mute Sound Effects", systemImage: soundManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
            }
            .tint(.purple)
        } header: {
            Text("Audio & Feedback")
        } footer: {
            Text("Control game sound effects when playing rounds.")
        }
    }
    
    // section for managing persistent storage and resetting history
    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                HStack {
                    Label("Reset All Statistics", systemImage: "trash.fill")
                    Spacer()
                }
            }
        } header: {
            Text("Data Management")
        } footer: {
            Text("Permanently erase all stored game records, high scores, and map pins.")
        }
    }
    
    // section detailing project information
    private var aboutSection: some View {
        Section {
            HStack {
                Label("App Version", systemImage: "info.circle.fill")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Coursework", systemImage: "graduationcap.fill")
                Spacer()
                Text("iOS Week 4 Project")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Storage Engine", systemImage: "internaldrive.fill")
                Spacer()
                Text("UserDefaults JSON")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}

#Preview {
    SettingsTab()
}
