//
//  AnimatedBackground.swift
//  myapp-1
//
//  Provides a modern, subtle gradient background with dark mode support.
//

import SwiftUI

struct AnimatedBackground: View {
    var colors: [Color] = [
        Color.blue.opacity(0.12),
        Color.purple.opacity(0.12)
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
