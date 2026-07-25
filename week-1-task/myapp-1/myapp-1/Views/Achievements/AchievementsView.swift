//
//  AchievementsView.swift
//  myapp-1
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var achievementService = AchievementService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("GAME ACHIEVEMENTS")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                    
                    Text("\(unlockedCount) of \(achievementService.achievements.count) Unlocked")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding(.top, 12)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(achievementService.achievements) { ach in
                        achievementCard(ach)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 90)
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(AppTheme.Colors.secondaryBackground.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private var unlockedCount: Int {
        achievementService.achievements.filter { $0.isUnlocked }.count
    }
    
    private func achievementCard(_ ach: Achievement) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(ach.isUnlocked ? Color.orange.opacity(0.2) : Color.gray.opacity(0.12))
                    .frame(width: 54, height: 54)
                
                Image(systemName: ach.isUnlocked ? ach.iconName : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(ach.isUnlocked ? .orange : .gray)
            }
            
            VStack(spacing: 4) {
                Text(ach.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ach.isUnlocked ? .primary : .gray)
                    .multilineTextAlignment(.center)
                
                Text(ach.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption2)
                    .foregroundColor(ach.isUnlocked ? .orange : .gray)
                Text("+\(ach.coinReward)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(ach.isUnlocked ? .orange : .gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(ach.isUnlocked ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(ach.isUnlocked ? Color.orange.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
}
