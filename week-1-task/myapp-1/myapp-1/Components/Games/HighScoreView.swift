//
//  HighScoreView.swift
//  myapp-1
//

import SwiftUI

struct HighScoreView: View {
    let highScore: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("HIGH SCORE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Text("\(highScore)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.15))
        )
    }
}

#Preview {
    HighScoreView(highScore: 250)
        .padding()
}
