//
//  TimerView.swift
//  myapp-1
//
//  Displays the remaining game time with visual alerts when time is low.
//

import SwiftUI

struct TimerView: View {
    let timeRemaining: Int
    let totalTime: Int
    
    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }
    
    private var timerColor: Color {
        if timeRemaining <= 3 {
            return .red
        } else if timeRemaining <= 5 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(timerColor)
                Text("TIME")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(timeRemaining)s")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(timerColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(timerColor)
                        .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 8)
                        .animation(.linear(duration: 1.0), value: timeRemaining)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        TimerView(timeRemaining: 8, totalTime: 10)
        TimerView(timeRemaining: 2, totalTime: 10)
    }
    .padding()
}
