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
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 64, height: 64)
                
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
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
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    VStack {
        NavigationCard(title: "Tap Frenzy", subtitle: "Tap fast before time runs out!", iconName: "hand.tap.fill", accentColor: .blue)
    }
    .padding()
}
