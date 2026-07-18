//
//  HomeGamesSection.swift
//  myapp-1
//
//  Houses the navigation cards leading to the 3 coursework games (Tap Frenzy, Light It Up, Quiz Rush).
//

import SwiftUI

struct HomeGamesSection: View {
    var body: some View {
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
