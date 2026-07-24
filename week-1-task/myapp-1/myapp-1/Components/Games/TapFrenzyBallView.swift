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
        let activeIcon = MarketplaceService.shared.catalogue.first(where: { $0.id == activeSkinId })?.iconName ?? "hand.tap.fill"
        
        ZStack {
            if isTrapActive {
                Circle()
                    .fill(Color.red)
                    .shadow(color: Color.red.opacity(0.5), radius: 15, x: 0, y: 8)
                
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: buttonDiameter * 0.4, height: buttonDiameter * 0.4)
                        .foregroundColor(.white)
                    
                    Text("TRAP!")
                        .font(.system(size: buttonDiameter * 0.18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            } else {
                if activeSkinId == "skin_bomb" {
                    BombVectorView()
                        .frame(width: buttonDiameter, height: buttonDiameter)
                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 0, y: 8)
                    
                    Text("TAP!")
                        .font(.system(size: buttonDiameter * 0.18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: buttonDiameter * 0.1) // slightly offset to sit on the belly of the bomb
                } else {
                    Circle()
                        .fill(skinColor)
                        .shadow(color: skinColor.opacity(0.5), radius: 15, x: 0, y: 8)
                    
                    VStack(spacing: 4) {
                        CustomArtworkResolver(itemId: activeSkinId, iconName: activeIcon)
                            .frame(width: buttonDiameter * 0.4, height: buttonDiameter * 0.4)
                            .foregroundColor(.white)
                        
                        Text("TAP!")
                            .font(.system(size: buttonDiameter * 0.18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(width: buttonDiameter, height: buttonDiameter)
    }
    
    private var skinColor: Color {
        if activeSkinId == "skin_lightning" {
            return .yellow
        } else {
            return .blue // default
        }
    }
}
