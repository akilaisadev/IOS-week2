//
//  NavigationCard.swift
//  myapp-1
//
//  A rich card view used on the Home screen to launch mini-games.
//

import SwiftUI

struct NavigationCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let accentColor: Color
    
    var body: some View {
        AppCard(padding: AppTheme.Spacing.small) {
            HStack(spacing: AppTheme.Spacing.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 26))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(AppTheme.Spacing.extraSmall)
        }
    }
}

#Preview {
    VStack {
        NavigationCard(title: "Tap Frenzy", subtitle: "Tap fast before time runs out!", iconName: "hand.tap.fill", accentColor: .blue)
    }
    .padding()
}
