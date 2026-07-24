//
//  AchievementToastView.swift
//  myapp-1
//

import SwiftUI

struct AchievementToastView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    var body: some View {
        AppCard(padding: AppTheme.Spacing.small) {
            HStack(spacing: AppTheme.Spacing.extraSmall) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.secondary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("ACHIEVEMENT UNLOCKED!")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(AppTheme.Colors.secondary)
                    
                    Text(achievement.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(achievement.description)
                        .font(.caption2)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                AppChip(text: "+\(achievement.coinReward)", icon: "dollarsign.circle.fill", color: AppTheme.Colors.secondary)
            }
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            onDismiss()
        }
    }
}

#Preview {
    AchievementToastView(
        achievement: Achievement(id: "test", title: "Century Club", description: "Score 100+ points", iconName: "crown.fill", coinReward: 75),
        onDismiss: {}
    )
}
