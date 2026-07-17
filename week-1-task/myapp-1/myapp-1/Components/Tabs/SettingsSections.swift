//
//  SettingsSections.swift
//  myapp-1
//

import SwiftUI

struct SettingsSections: View {
    @ObservedObject var notificationService: NotificationService
    @ObservedObject var soundManager: SoundManager
    @Binding var moveTrophyRoomToBottom: Bool
    @Binding var showingResetAlert: Bool
    
    var body: some View {
        notificationsSection
        audioSection
        layoutSection
        dataSection
        aboutSection
    }
    
    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $notificationService.isEnabled) {
                Label("Daily Reminders", systemImage: "bell.fill")
            }
            .tint(.blue)
            .onChange(of: notificationService.isEnabled) { _, _ in
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
                .onChange(of: notificationService.reminderTime) { _, _ in
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
    
    private var layoutSection: some View {
        Section {
            Toggle(isOn: $moveTrophyRoomToBottom) {
                Label("Trophy Room at Bottom", systemImage: "arrow.up.arrow.down")
            }
            .tint(.orange)
        } header: {
            Text("Home Layout")
        } footer: {
            Text("When enabled, the Trophy Room & Leaderboard card is moved to the bottom below the games list. When off, it returns to the top.")
        }
    }
    
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
                Text("iOS 4 Week Project")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
