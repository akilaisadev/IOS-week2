//
//  ProfileAvatarHeader.swift
//  myapp-1
//

import SwiftUI

struct ProfileAvatarHeader: View {
    @ObservedObject private var walletService = WalletService.shared
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    @AppStorage("playerName") private var playerName = "Player 1"
    
    let selectedFrame: AvatarFrameStyle
    let onEditTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: selectedFrame.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 80, height: 80)
                
                let activeAvatar = marketplaceService.catalogue.first(where: { $0.id == marketplaceService.activeAvatarId })?.iconName ?? "person.fill"
                
                CustomArtworkResolver(itemId: marketplaceService.activeAvatarId, iconName: activeAvatar)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.primary)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: onEditTapped) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                        }
                    }
                }
                .frame(width: 90, height: 90)
                .offset(x: 5, y: 5)
            }
            .shadow(color: selectedFrame.gradientColors.first?.opacity(0.4) ?? .clear, radius: 10, x: 0, y: 5)
            
            VStack(spacing: 4) {
                Text(playerName.isEmpty ? "Player 1" : playerName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 6) {
                    Text("LEVEL \(walletService.wallet.level)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                    
                    CoinBadge(coins: walletService.wallet.coins)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}
