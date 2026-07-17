//
//  AnimatedBackground.swift
//  myapp-1
//

import SwiftUI

struct AnimatedBackground: View {
    var colors: [Color] = [
        Color.blue.opacity(0.14),
        Color.purple.opacity(0.18)
    ]
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AnimatedBackground()
}
