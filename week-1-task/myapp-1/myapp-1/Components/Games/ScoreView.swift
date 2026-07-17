//
//  ScoreView.swift
//  myapp-1
//

import SwiftUI

struct ScoreView: View {
    let score: Int
    var multiplier: Int = 1
    var streak: Int? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Text("\(score)")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            if multiplier > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                    Text("\(multiplier)x COMBO")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .clipShape(Capsule())
            }
            
            if let streak = streak, streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                    Text("\(streak) STREAK")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    VStack {
        ScoreView(score: 120, multiplier: 3)
        ScoreView(score: 45, streak: 5)
    }
    .padding()
}
