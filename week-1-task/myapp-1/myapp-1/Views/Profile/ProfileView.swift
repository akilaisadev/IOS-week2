//  ProfileView.swift - myapp-1 (Dedicated Player Profile & Achievements Hub)

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var walletService = WalletService.shared
    @ObservedObject private var achievementService = AchievementService.shared
    @ObservedObject private var historyService = HistoryService.shared
    @ObservedObject private var referralService = ReferralService.shared
    @AppStorage("playerName") private var playerName = "Player 1"
    
    @State private var selectedFrame: AvatarFrameStyle = .defaultFrame
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeaderCard
                xpProgressCard
                statsOverviewGrid
                achievementsShelfSection
                referralCardSection
                
                Spacer(minLength: 30)
            }
            .padding(.vertical)
        }
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Header card displaying avatar ring, gamer tag, and coin badge
    private var profileHeaderCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: selectedFrame.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
            }
            .shadow(color: selectedFrame.gradientColors.first?.opacity(0.4) ?? .clear, radius: 10, x: 0, y: 5)
            
            VStack(spacing: 4) {
                Text(playerName.isEmpty ? "Player 1" : playerName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 6) {
                    Text("LEVEL \(walletService.wallet.level)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                    
                    CoinBadge(coins: walletService.wallet.coins)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
    
    // XP progression bar showing level progression
    private var xpProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("LEVEL PROGRESSION")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(walletService.wallet.xp) / \(walletService.wallet.xpForNextLevel) XP")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
            
            ProgressView(value: Double(walletService.wallet.xp), total: Double(walletService.wallet.xpForNextLevel))
                .tint(.purple)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    // Lifetime game statistics grid
    private var statsOverviewGrid: some View {
        HStack(spacing: 12) {
            statItem(title: "Games Played", value: "\(historyService.sessions.count)", icon: "gamecontroller.fill", color: .blue)
            statItem(title: "Total Points", value: "\(historyService.totalCombinedScore)", icon: "star.fill", color: .orange)
            statItem(title: "Badges", value: "\(unlockedBadgesCount)/\(achievementService.achievements.count)", icon: "medal.fill", color: .purple)
        }
        .padding(.horizontal)
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
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
