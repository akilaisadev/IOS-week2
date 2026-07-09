//
//  ReadyPromptView.swift
//  myapp-1
//
//  A sleek, high-visual-hierarchy "Are You Ready?" startup overlay
//  that ensures the gamer is prepared before the game timer starts.
//

import SwiftUI

struct ReadyPromptView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let themeColor: Color
    let onReady: () -> Void
    
    @State private var isPulseAnimated = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated Icon Header
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.18))
                        .frame(width: 90, height: 90)
                        .scaleEffect(isPulseAnimated ? 1.15 : 0.95)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulseAnimated)
                    
                    Circle()
                        .fill(themeColor.opacity(0.35))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(themeColor)
                        .shadow(color: themeColor.opacity(0.5), radius: 6)
                }
                
                // Title & Instructions
                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                }
                
                // Big Action Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        onReady()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.headline)
                        Text("I'M READY - START!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(themeColor)
                            .shadow(color: themeColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                }
                .padding(.horizontal, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.35), radius: 25, x: 0, y: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(themeColor.opacity(0.3), lineWidth: 1.5)
            )
            .padding(.horizontal, 32)
            .scaleEffect(isPulseAnimated ? 1.01 : 0.99)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulseAnimated)
        }
        .onAppear {
            isPulseAnimated = true
        }
    }
}

#Preview {
    ReadyPromptView(
        title: "ARE YOU READY?",
        subtitle: "Tap the circle as fast as you can! Watch out for red traps!",
        iconName: "hand.tap.fill",
        themeColor: .blue,
        onReady: {}
    )
}
