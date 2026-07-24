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
        VStack(spacing: 4) {
            Image(systemName: isTrapActive ? "exclamationmark.octagon.fill" : activeSkinId)
                .font(.system(size: buttonDiameter * 0.25))
            
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
        if activeSkinId == "flame.fill" {
            return .black
        } else if activeSkinId == "bolt.fill" {
            return .yellow
        } else {
            return .blue // default hand.tap
        }
    }
}
