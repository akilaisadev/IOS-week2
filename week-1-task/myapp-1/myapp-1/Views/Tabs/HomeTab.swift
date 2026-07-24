//
//  HomeTab.swift
//  myapp-1
//
//  home screen tab showing our 3 coursework mini games and trophy room
//

import SwiftUI

struct HomeTab: View {
    @StateObject private var historyService = HistoryService.shared
    @StateObject private var walletService = WalletService.shared
    @StateObject private var streakService = StreakService.shared
    @AppStorage("moveTrophyRoomToBottom") private var moveTrophyRoomToBottom = false
    @AppStorage("hasEnteredPlayerDetails") private var hasEnteredPlayerDetails = false
    @AppStorage("playerName") private var playerName = "Player 1"
    @State private var showingOnboarding = false
    @State private var showingMarketplace = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground(colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.12)])
                
                ScrollView {
                    VStack(spacing: 24) {
                        HStack(spacing: 10) {
                            StreakBadge(streakDays: streakService.currentStreak)
                            
                            Spacer()
                            
                            Button {
                                showingMarketplace = true
                            } label: {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            
                            CoinBadge(coins: walletService.wallet.coins) {
                                showingMarketplace = true
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if let banner = streakService.streakBannerMessage {
                            HStack {
                                Text(banner)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    streakService.dismissBanner()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        titleHeader
                        if moveTrophyRoomToBottom {
                            gamesListSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            quickStatsGrid
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            quickStatsGrid
                                .transition(.move(edge: .top).combined(with: .opacity))
                            gamesListSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                    }
                    .padding(.bottom, 120)
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: moveTrophyRoomToBottom)
                }
            }
            .blur(radius: showingOnboarding ? 8 : 0)
            .disabled(showingOnboarding)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMarketplace) {
                MarketplaceView()
            }
            .sheet(isPresented: $showingOnboarding, onDismiss: {
                LocationService.shared.requestPermission()
            }) {
                PlayerOnboardingView()
                    .interactiveDismissDisabled()
            }
            .onAppear {
                if !hasEnteredPlayerDetails {
                    showingOnboarding = true
                } else {
                    LocationService.shared.requestPermission()
                }
            }
        }
    }
    private var titleHeader: some View {
        VStack(spacing: AppTheme.Spacing.extraSmall) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.primaryGradient)
            
            Text("GameHub")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
            
            Text(playerName == "Player 1" || playerName.isEmpty ? "iOS Mini-Game Collection" : "Welcome back, \(playerName)!")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            NavigationLink(destination: ProfileView()) {
                HStack(spacing: AppTheme.Spacing.extraSmall) {
                    AppChip(text: "LEVEL \(walletService.wallet.level)", color: AppTheme.Colors.primary, isActive: true)
                    
                    Text("\(walletService.wallet.xp) XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(.top, AppTheme.Spacing.extraSmall)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, AppTheme.Spacing.small)
    }
    
    private var quickStatsGrid: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            trophyRoomCard
            achievementsCard
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
    }
    
    private var trophyRoomCard: some View {
        NavigationLink(destination: LeaderboardView()) {
            AppCard(padding: AppTheme.Spacing.medium) {
                HStack(spacing: AppTheme.Spacing.small) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trophy Room")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text("Total Combined Score: \(historyService.totalCombinedScore) PTS")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var achievementsCard: some View {
        NavigationLink(destination: AchievementsView()) {
            AppCard(padding: AppTheme.Spacing.medium) {
                HStack(spacing: AppTheme.Spacing.small) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.secondary.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "medal.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Game Achievements")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text("\(AchievementService.shared.achievements.filter { $0.isUnlocked }.count) / \(AchievementService.shared.achievements.count) Badges Unlocked")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
    private var gamesListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MINI GAMES")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                NavigationLink(destination: TapFrenzyView()) {
                    NavigationCard(
                        title: "Tap Frenzy",
                        subtitle: "Test your reflexes in this fast-paced tapping challenge.",
                        iconName: "hand.tap.fill",
                        accentColor: .blue
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: LightItUpView()) {
                    NavigationCard(
                        title: "Light It Up",
                        subtitle: "Memorize and repeat the glowing patterns to survive.",
                        iconName: "sparkles",
                        accentColor: .orange
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: QuizRushView()) {
                    NavigationCard(
                        title: "Quiz Rush",
                        subtitle: "Race against the clock in this exciting live trivia game!",
                        iconName: "questionmark.bubble.fill",
                        accentColor: .purple
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeTab()
}
typealias HomeView = HomeTab

