//
//  MarketplaceItemCard.swift
//  myapp-1
//

import SwiftUI

struct MarketplaceItemCard: View {
    let item: MarketplaceItem
    let quantityOwned: Int
    let onPurchase: () -> Void
    
    @StateObject private var walletService = WalletService.shared
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: item.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let badge = item.badgeText {
                        Text(badge)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(categoryColor)
                            .clipShape(Capsule())
                    }
                }
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button {
                onPurchase()
            } label: {
                VStack(spacing: 2) {
                    if !item.isStackable && quantityOwned > 0 {
                        Text("OWNED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(walletService.wallet.isDeveloperMode ? "FREE" : "\(item.price)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(walletService.wallet.isDeveloperMode ? Color.red : Color.blue)
                        )
                        
                        if quantityOwned > 0 {
                            Text("\(quantityOwned) Owned")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!item.isStackable && quantityOwned > 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
    
    private var categoryColor: Color {
        switch item.category {
        case .powerUps: return .green
        case .boosters: return .orange
        case .cosmetics: return .purple
        case .avatars: return .blue
        case .skins: return .red
        }
    }
}
