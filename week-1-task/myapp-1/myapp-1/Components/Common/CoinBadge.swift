//
//  CoinBadge.swift
//  myapp-1
//

import SwiftUI

struct CoinBadge: View {
    let coins: Int
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
                Text("\(coins)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.75))
                    .shadow(color: Color.yellow.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CoinBadge(coins: 240)
}
