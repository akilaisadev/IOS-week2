//
//  PowerUpSelectionView.swift
//  myapp-1
//

import SwiftUI

struct PowerUpSelectionView: View {
    @ObservedObject private var powerUpService = PowerUpService.shared
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text("SELECT POWER-UP FOR THIS ROUND")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                ForEach(PowerUpType.allCases) { type in
                    let qty = quantity(for: type)
                    let isActive = powerUpService.activePowerUp == type
                    
                    Button {
                        if isActive {
                            powerUpService.clearActivePowerUp()
                        } else if qty > 0 {
                            _ = powerUpService.activatePowerUp(type)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.iconName)
                                .font(.title2)
                                .foregroundColor(isActive ? .white : (qty > 0 ? type.themeColor : .gray))
                            
                            Text(type.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isActive ? .white : (qty > 0 ? .primary : .gray))
                                .lineLimit(1)
                            
                            Text(qty > 0 ? "\(qty) Left" : "0 Owned")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(isActive ? .white.opacity(0.8) : .secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isActive ? type.themeColor : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isActive ? Color.white : (qty > 0 ? type.themeColor.opacity(0.4) : Color.clear), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(qty == 0 && !isActive)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
    
    private func quantity(for type: PowerUpType) -> Int {
        switch type {
        case .doubleCoins: return marketplaceService.quantity(for: "power_double_coins")
        case .scoreShield: return marketplaceService.quantity(for: "power_score_shield")
        case .timeFreezer: return marketplaceService.quantity(for: "power_time_freezer")
        }
    }
}

#Preview {
    PowerUpSelectionView()
}
