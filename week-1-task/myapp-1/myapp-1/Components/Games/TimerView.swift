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
        AppCard(padding: AppTheme.Spacing.small) {
            VStack(spacing: AppTheme.Spacing.extraSmall) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(timerColor)
                    Text("TIME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(timerColor)
                }
                
                AppProgressBar(value: Double(timeRemaining), total: Double(totalTime), color: timerColor)
            }
        }
    }
}

#Preview {
    VStack {
        TimerView(timeRemaining: 8, totalTime: 10)
        TimerView(timeRemaining: 2, totalTime: 10)
    }
    .padding()
}
