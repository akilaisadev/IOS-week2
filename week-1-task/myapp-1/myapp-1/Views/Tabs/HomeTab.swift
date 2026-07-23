//
//  HomeTab.swift
//  myapp-1
//
//  home screen tab showing our 3 coursework mini games and trophy room
//

import SwiftUI

struct HomeTab: View {
    @ObservedObject private var historyService = HistoryService.shared
    @ObservedObject private var walletService = WalletService.shared
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
                        HStack {
                            Spacer()
                            CoinBadge(coins: walletService.wallet.coins) {
                                showingMarketplace = true
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        titleHeader
                        if moveTrophyRoomToBottom {
                            gamesListSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            trophyRoomCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                            achievementsCard
                        } else {
                            trophyRoomCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                            achievementsCard
                            gamesListSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        Spacer(minLength: 40)
                    }
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
        VStack(spacing: 6) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("GameHub")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
            
            Text(playerName == "Player 1" || playerName.isEmpty ? "iOS Mini-Game Collection" : "Welcome back, \(playerName)!")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
    private var trophyRoomCard: some View {
        NavigationLink(destination: LeaderboardView()) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.25))
                        .frame(width: 58, height: 58)
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trophy Room")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Total Combined Score: \(historyService.totalCombinedScore) PTS")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.yellow.opacity(0.2), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
    
    private var achievementsCard: some View {
        NavigationLink(destination: AchievementsView()) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.25))
                        .frame(width: 58, height: 58)
                    Image(systemName: "medal.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Game Achievements")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(AchievementService.shared.achievements.filter { $0.isUnlocked }.count) / \(AchievementService.shared.achievements.count) Badges Unlocked")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.orange.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
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

