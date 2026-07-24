//
//  MarketplaceItemCard.swift
//  myapp-1
//

import SwiftUI

struct MarketplaceItemCard: View {
    let item: MarketplaceItem
    let quantityOwned: Int
    let onPurchase: () -> Void
    
    @ObservedObject private var walletService = WalletService.shared
    
    // UI Wrapper properties
    private var uiModel: MarketplaceUIWrapper {
        MarketplaceUIHelper.wrap(item)
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            onPurchase()
        } label: {
            VStack(spacing: 0) {
                // Top Half: Artwork & Rarity
                ZStack(alignment: .topTrailing) {
                    // Rarity Background Gradient
                    LinearGradient(
                        colors: [uiModel.rarity.color.opacity(0.6), uiModel.rarity.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack {
                        Spacer()
                        if !item.isSystemImage {
                            Image(item.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .shadow(color: uiModel.rarity.color.opacity(0.8), radius: 8, x: 0, y: 0)
                        } else {
                            Image(systemName: item.iconName)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .shadow(color: uiModel.rarity.color.opacity(0.8), radius: 8, x: 0, y: 0)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Badges
                    VStack(alignment: .trailing, spacing: 6) {
                        if quantityOwned > 0 {
                            Text("\(quantityOwned)x")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.black.opacity(0.6)))
                        }
                        if let badge = item.badgeText {
                            Text(badge)
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(uiModel.rarity.color))
                        }
                    }
                    .padding(8)
                }
                .frame(height: 110)
                
                // Bottom Half: Text & Price
                VStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Text(item.description)
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(height: 28) // Fixed height for 2 lines
                    
                    Spacer(minLength: 0)
                    
                    // Purchase Button Area
                    HStack(spacing: 4) {
                        if !item.isStackable && quantityOwned > 0 {
                            Text("OWNED")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                        } else {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(walletService.wallet.isDeveloperMode ? "FREE" : "\(item.price)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(!item.isStackable && quantityOwned > 0 ? Color.gray.opacity(0.3) : (walletService.wallet.isDeveloperMode ? Color.red : Color.blue))
                    )
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(uiModel.rarity.color.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(MarketplaceCardButtonStyle(isPressed: $isPressed))
        .disabled(!item.isStackable && quantityOwned > 0)
    }
}

// Custom button style to track press state for animations
struct MarketplaceCardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}
