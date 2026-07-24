//
//  SettingsTab.swift
//  myapp-1
//
//  tab view for application settings and preferences
//

import SwiftUI

struct SettingsTab: View {
    enum SaveStatus: Equatable {
        case idle, saving, saved, error(String)
    }
    
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var soundManager = SoundManager.shared
    @State private var showingResetAlert = false
    @AppStorage("moveTrophyRoomToBottom") private var moveTrophyRoomToBottom = false
    @AppStorage("playerName") private var playerName = "Player 1"
    
    @State private var inputTag = ""
    @State private var saveStatus: SaveStatus = .idle
    @State private var saveTask: DispatchWorkItem? = nil
    
    @StateObject private var walletService = WalletService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                Form {
                    WalletHeaderView()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom, 8)
                    
                    profileSection
                    referralSection
                    developerSection
                    notificationsSection
                    audioSection
                    layoutSection
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
            .onAppear {
                inputTag = playerName
            }
            .onDisappear {
                forceSaveOnExit()
            }
        }
    }
    private var profileSection: some View {
        Section {
            NavigationLink(destination: ProfileView()) {
                HStack(spacing: AppTheme.Spacing.small) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("My Profile & Badges Shelf")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("Level \(walletService.wallet.level) • \(walletService.wallet.xp) XP")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.secondary)
                            .fontWeight(.bold)
                    }
                }
                .padding(.vertical, 4)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                TextField("Gamer Tag (2-16 chars)", text: $inputTag)
                    .onChange(of: inputTag) { _, newValue in
                        validateAndSave(newValue)
                    }
                    .onSubmit {
                        forceSaveOnExit()
                    }
                if case .saving = saveStatus {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.75)
                        Text("Saving...")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else if case .saved = saveStatus {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.success)
                        Text("Saved instantly")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.success)
                    }
                    .transition(.opacity.combined(with: .scale))
                } else if case .error(let msg) = saveStatus {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppTheme.Colors.error)
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.error)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: saveStatus)
        } header: {
            Text("Player Profile").font(.subheadline)
        } footer: {
            Text("Your gamer tag is shown on your home dashboard and shared high score cards.")
        }
    }
    
    private func validateAndSave(_ tag: String) {
        saveTask?.cancel()
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            withAnimation { saveStatus = .error("Name cannot be empty") }
            return
        }
        guard trimmed.count >= 2 else {
            withAnimation { saveStatus = .error("Name must be at least 2 characters") }
            return
        }
        guard trimmed.count <= 16 else {
            withAnimation { saveStatus = .error("Maximum 16 characters allowed") }
            return
        }
        
        withAnimation { saveStatus = .saving }
        
        let workItem = DispatchWorkItem {
            playerName = trimmed
            withAnimation { saveStatus = .saved }
        }
        saveTask = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
    
    private func forceSaveOnExit() {
        saveTask?.cancel()
        let trimmed = inputTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 2 && trimmed.count <= 16 {
            playerName = trimmed
        } else if !playerName.isEmpty && playerName.count >= 2 && playerName.count <= 16 {
            inputTag = playerName
        } else {
            playerName = "Player 1"
            inputTag = "Player 1"
        }
        withAnimation { saveStatus = .idle }
    }
    private var referralSection: some View {
        Section {
            NavigationLink(destination: ReferralView()) {
                Label("Referral & Rewards", systemImage: "person.2.gift.fill")
            }
        } header: {
            Text("Rewards & Referral")
        } footer: {
            Text("Invite friends using your unique referral code to earn 50 bonus GameCoins.")
        }
    }
    
    private var developerSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { walletService.wallet.isDeveloperMode },
                set: { _ in walletService.toggleDeveloperMode() }
            )) {
                Label("Developer Mode (Free Marketplace)", systemImage: "hammer.fill")
            }
            .tint(.red)
            
            if walletService.wallet.isDeveloperMode {
                Button {
                    walletService.grantDevCoins()
                } label: {
                    HStack {
                        Label("Grant +10,000 Test Coins", systemImage: "plus.circle.fill")
                            .foregroundColor(.orange)
                        Spacer()
                    }
                }
            }
        } header: {
            Text("Developer & Testing Controls")
        } footer: {
            Text("Developer Mode grants free purchases in the marketplace for quick testing.")
        }
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
            Text("When enabled, the Trophy Room card is moved to the bottom below the games list. When off, it returns to the top.")
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

#Preview {
    SettingsTab()
}
