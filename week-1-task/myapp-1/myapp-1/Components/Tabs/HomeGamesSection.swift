//
//  HomeGamesSection.swift
//  myapp-1
//

import SwiftUI

struct HomeGamesSection: View {
    var body: some View {
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
