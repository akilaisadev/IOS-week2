//
//  HomeTab.swift
//  myapp-1
//
//  home screen tab showing our 3 coursework mini games and trophy room
//

import SwiftUI

struct HomeTab: View {
    @ObservedObject private var historyService = HistoryService.shared
    @AppStorage("moveTrophyRoomToBottom") private var moveTrophyRoomToBottom = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground(colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.12)])
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Header
                        titleHeader
                        
                        // Conditional layout based on moveTrophyRoomToBottom setting
                        if moveTrophyRoomToBottom {
                            gamesListSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            trophyRoomCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            trophyRoomCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                            gamesListSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: moveTrophyRoomToBottom)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                LocationService.shared.requestPermission()
            }
        }
    }
    
    // Title Header Section
    private var titleHeader: some View {
        VStack(spacing: 6) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("GameHub")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
            
            Text("iOS Mini-Game Collection")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
    
    // Trophy Room / Leaderboard Hero Banner
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
                    Text("Trophy Room & Leaderboard")
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
    
    // Game Navigation Cards Section
    private var gamesListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MY GAMES")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                NavigationLink(destination: TapFrenzyView()) {
                    NavigationCard(
                        title: "Tap Frenzy",
                        subtitle: "High-speed reflex challenge with combo multipliers & traps.",
                        iconName: "hand.tap.fill",
                        accentColor: .blue
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: LightItUpView()) {
                    NavigationCard(
                        title: "Light It Up",
                        subtitle: "Grid reflex game featuring 4 difficulty tiers & 3-life system.",
                        iconName: "sparkles",
                        accentColor: .orange
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: QuizRushView()) {
                    NavigationCard(
                        title: "Quiz Rush",
                        subtitle: "Async/await live trivia questions powered by OpenTDB.",
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

// backward compatibility alias
typealias HomeView = HomeTab

