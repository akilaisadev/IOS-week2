//
//  CountdownOverlayView.swift
//  myapp-1
//
//  Displays a pulsing 3-2-1-GO! countdown overlay before gameplay begins.
//

import SwiftUI

struct CountdownOverlayView: View {
    let countdown: Int
    var themeColor: Color = .blue
    
    @State private var isScaled = false
    
    private var displayText: String {
        if countdown == 0 {
            return "GO!"
        } else {
            return "\(countdown)"
        }
    }
    
    private var displayColor: Color {
        if countdown == 0 {
            return .green
        } else if countdown == 1 {
            return .orange
        } else {
            return themeColor
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(displayColor.opacity(0.25))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isScaled ? 1.2 : 0.8)
                    .opacity(isScaled ? 0.3 : 0.8)
                
                Circle()
                    .stroke(displayColor.opacity(0.6), lineWidth: 6)
                    .frame(width: 170, height: 170)
                    .scaleEffect(isScaled ? 1.05 : 0.95)
                
                Text(displayText)
                    .font(.system(size: countdown == 0 ? 70 : 90, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: displayColor.opacity(0.8), radius: 15, x: 0, y: 5)
            }
            .id(countdown)
            .scaleEffect(isScaled ? 1.0 : 0.5)
            .opacity(isScaled ? 1.0 : 0.0)
            .onAppear {
                triggerPulse()
            }
            .onChange(of: countdown) { _, _ in
                triggerPulse()
            }
        }
        .transition(.opacity)
    }
    
    private func triggerPulse() {
        isScaled = false
        withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
            isScaled = true
        }
    }
}

#Preview {
    CountdownOverlayView(countdown: 3, themeColor: .blue)
}
