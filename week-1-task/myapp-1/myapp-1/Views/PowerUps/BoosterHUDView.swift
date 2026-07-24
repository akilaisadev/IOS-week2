//
//  BoosterHUDView.swift
//  myapp-1
//

import SwiftUI

struct BoosterHUDView: View {
    let boosterID: String
    let iconName: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var usesInCurrentRound = 0
    let maxUses = 2
    
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    
    var body: some View {
        let count = marketplaceService.quantity(for: boosterID)
        
        if count > 0 && usesInCurrentRound < maxUses {
            Button {
                if marketplaceService.consumeItem(id: boosterID) {
                    usesInCurrentRound += 1
                    action()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: iconName)
                    Text(title)
                    Text("(\(count))")
                        .font(.system(size: 9, weight: .black))
                        .padding(.leading, 2)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(color)
                .clipShape(Capsule())
                .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
            }
        }
    }
}
