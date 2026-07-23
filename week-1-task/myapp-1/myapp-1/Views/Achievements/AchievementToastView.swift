//
//  AchievementToastView.swift
//  myapp-1
//

import SwiftUI

struct AchievementToastView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("ACHIEVEMENT UNLOCKED!")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.orange)
                
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(achievement.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("🪙")
                    .font(.caption2)
                Text("+\(achievement.coinReward)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1.5)
        )
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
