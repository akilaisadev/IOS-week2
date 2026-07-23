//
//  StreakBadge.swift
//  myapp-1
//

import SwiftUI

struct StreakBadge: View {
    let streakDays: Int
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.orange)
            Text("Day \(streakDays)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
        )
    }
}

#Preview {
    StreakBadge(streakDays: 5)
}
