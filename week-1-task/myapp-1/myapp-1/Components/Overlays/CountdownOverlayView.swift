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
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(displayColor.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isScaled ? 1.3 : 0.8)
                    .opacity(isScaled ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 0.8), value: isScaled)
                
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .background(Circle().fill(.ultraThinMaterial))
                    .shadow(color: displayColor.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Circle()
                    .stroke(displayColor.opacity(0.8), lineWidth: 2)
                    .frame(width: 140, height: 140)
                
                Text(displayText)
                    .font(.system(size: countdown == 0 ? 55 : 65, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: displayColor, radius: 10, x: 0, y: 0)
            }
            .id(countdown)
            .scaleEffect(isScaled ? 1.0 : 0.4)
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
