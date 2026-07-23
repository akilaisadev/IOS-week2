//
//  WalletHeaderView.swift
//  myapp-1
//

import SwiftUI

struct WalletHeaderView: View {
    @ObservedObject private var walletService = WalletService.shared
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("LEVEL \(walletService.wallet.level)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                        
                        if walletService.wallet.isDeveloperMode {
                            Text("DEV MODE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("XP: \(walletService.wallet.xp) / \(walletService.wallet.xpForNextLevel)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CoinBadge(coins: walletService.wallet.coins)
            }
            
            ProgressView(value: Double(walletService.wallet.xp), total: Double(walletService.wallet.xpForNextLevel))
                .tint(.purple)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    WalletHeaderView()
        .padding()
}
