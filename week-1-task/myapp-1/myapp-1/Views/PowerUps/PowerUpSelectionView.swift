//
//  PowerUpSelectionView.swift
//  myapp-1
//

import SwiftUI

struct PowerUpSelectionView: View {
    @ObservedObject private var powerUpService = PowerUpService.shared
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    
    @State private var itemToBuy: MarketplaceItem?
    @State private var alertMessage: String?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("SELECT POWER-UP FOR THIS ROUND")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                let availableTypes = PowerUpType.allCases
                
                ForEach(availableTypes) { type in
                    let qty = quantity(for: type)
                    let isActive = powerUpService.activePowerUp == type
                    let item = marketplaceItem(for: type)
                    
                    Button {
                        if isActive {
                            powerUpService.clearActivePowerUp()
                        } else if qty > 0 {
                            _ = powerUpService.activatePowerUp(type)
                        } else if let item = item {
                            itemToBuy = item
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.iconName)
                                .font(.title2)
                                .foregroundColor(isActive ? .white : type.themeColor)
                            
                            Text(type.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isActive ? .white : .primary)
                                .lineLimit(1)
                            
                            if qty > 0 {
                                Text(isActive ? "Equipped" : "\(qty) Left")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(isActive ? .white.opacity(0.8) : .secondary)
                            } else {
                                Text(item != nil ? "Buy \(item!.price)🪙" : "0 Left")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.blue)
                            }
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
                                .stroke(isActive ? Color.white : type.themeColor.opacity(0.4), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
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
        .sheet(item: $itemToBuy) { item in
            MarketplacePreviewSheet(
                item: item,
                onPurchase: { handlePurchase(item) }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert("Marketplace", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }
    
    private func quantity(for type: PowerUpType) -> Int {
        switch type {
        case .doubleCoins: return marketplaceService.quantity(for: "power_double_coins")
        case .scoreShield: return marketplaceService.quantity(for: "power_score_shield")
        case .timeFreezer: return marketplaceService.quantity(for: "power_time_freezer")
        }
    }
    
    private func marketplaceItem(for type: PowerUpType) -> MarketplaceItem? {
        let id: String
        switch type {
        case .doubleCoins: id = "power_double_coins"
        case .scoreShield: id = "power_score_shield"
        case .timeFreezer: id = "power_time_freezer"
        }
        return marketplaceService.catalogue.first { $0.id == id }
    }
    
    private func handlePurchase(_ item: MarketplaceItem) {
        if marketplaceService.purchase(item) {
            SoundManager.shared.playBonus()
            alertMessage = "Successfully purchased \(item.name)!"
        } else {
            alertMessage = "Not enough coins to purchase \(item.name)."
        }
    }
}

#Preview {
    PowerUpSelectionView()
}
