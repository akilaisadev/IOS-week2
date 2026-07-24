//  ProfileView.swift - myapp-1 (Dedicated Player Profile & Achievements Hub)

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var walletService = WalletService.shared
    @ObservedObject private var achievementService = AchievementService.shared
    @ObservedObject private var historyService = HistoryService.shared
    @ObservedObject private var referralService = ReferralService.shared
    @AppStorage("playerName") private var playerName = "Player 1"
    
    @State private var selectedFrame: AvatarFrameStyle = .defaultFrame
    
    @State private var showingAvatarSelection = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileAvatarHeader(selectedFrame: selectedFrame) {
                    showingAvatarSelection = true
                }
                
                xpProgressCard
                statsOverviewGrid
                achievementsShelfSection
                referralCardSection
                
                Spacer(minLength: 30)
            }
            .padding(.vertical)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90)
        }
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Colors.secondaryBackground.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingAvatarSelection) {
            AvatarSelectionSheet()
        }
    }
    
    // XP progression bar showing level progression
    private var xpProgressCard: some View {
        AppCard(padding: AppTheme.Spacing.small) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("LEVEL PROGRESSION")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Spacer()
                    Text("\(walletService.wallet.xp) / \(walletService.wallet.xpForNextLevel) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                AppProgressBar(value: Double(walletService.wallet.xp), total: Double(walletService.wallet.xpForNextLevel), color: AppTheme.Colors.primary)
            }
        }
        .padding(.horizontal)
    }
    
    // Lifetime game statistics grid
    private var statsOverviewGrid: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            AppStatCard(title: "Games Played", value: "\(historyService.sessions.count)", icon: "gamecontroller.fill", color: AppTheme.Colors.primary)
            AppStatCard(title: "Total Points", value: "\(historyService.totalCombinedScore)", icon: "star.fill", color: AppTheme.Colors.secondary)
            AppStatCard(title: "Badges", value: "\(unlockedBadgesCount)/\(achievementService.achievements.count)", icon: "medal.fill", color: AppTheme.Colors.primary)
        }
        .padding(.horizontal)
    }
    
    private var unlockedBadgesCount: Int {
        achievementService.achievements.filter { $0.isUnlocked }.count
    }
    
    // Achievement badges shelf section
    private var achievementsShelfSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ACHIEVEMENTS SHELF")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundColor(.secondary)
                Spacer()
                NavigationLink(destination: AchievementsView()) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievementService.achievements) { ach in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(ach.isUnlocked ? Color.orange.opacity(0.2) : Color.gray.opacity(0.12))
                                    .frame(width: 50, height: 50)
                                Image(systemName: ach.isUnlocked ? ach.iconName : "lock.fill")
                                    .font(.title3)
                                    .foregroundColor(ach.isUnlocked ? .orange : .gray)
                            }
                            Text(ach.title)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(ach.isUnlocked ? .primary : .gray)
                                .lineLimit(1)
                        }
                        .frame(width: 90, height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Referral card and code sharing
    private var referralCardSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Referral Code")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Share with friends to earn 50 GameCoins")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(walletService.wallet.referralCode)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            NavigationLink(destination: ReferralView()) {
                HStack {
                    Image(systemName: "person.2.gift.fill")
                    Text("Open Referral Hub")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.purple)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
