//
//  TapFrenzyBallView.swift
//  myapp-1
//

import SwiftUI

struct TapFrenzyBallView: View {
    let buttonDiameter: CGFloat
    let isTrapActive: Bool
    let activeSkinId: String
    
    var body: some View {
        let activeSkinItem = MarketplaceService.shared.catalogue.first(where: { $0.id == activeSkinId })
        let activeIcon = activeSkinItem?.iconName ?? "hand.tap.fill"
        
        VStack(spacing: 4) {
            if isTrapActive {
                Image(systemName: "exclamationmark.octagon.fill")
                    .font(.system(size: buttonDiameter * 0.25))
            } else if let item = activeSkinItem, !item.isSystemImage {
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonDiameter * 0.4, height: buttonDiameter * 0.4)
            } else {
                Image(systemName: activeIcon)
                    .font(.system(size: buttonDiameter * 0.25))
            }
            
            Text(isTrapActive ? "TRAP!" : "TAP!")
                .font(.system(size: buttonDiameter * 0.18, weight: .black, design: .rounded))
        }
        .foregroundColor(.white)
        .frame(width: buttonDiameter, height: buttonDiameter)
        .background(
            Circle()
                .fill(isTrapActive ? Color.red : skinColor)
                .shadow(color: (isTrapActive ? Color.red : skinColor).opacity(0.5), radius: 15, x: 0, y: 8)
        )
    }
    
    private var skinColor: Color {
        if activeSkinId == "skin_bomb" {
            return .black
        } else if activeSkinId == "skin_lightning" {
            return .yellow
        } else {
            return .blue // default
        }
    }
}
