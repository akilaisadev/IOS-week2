//
//  ActivePowerUpBanner.swift
//  myapp-1
//

import SwiftUI

struct ActivePowerUpBanner: View {
    let powerUp: PowerUpType
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: powerUp.iconName)
            Text("\(powerUp.rawValue) Active")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(powerUp.themeColor)
        .clipShape(Capsule())
        .shadow(color: powerUp.themeColor.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ActivePowerUpBanner(powerUp: .doubleCoins)
}
