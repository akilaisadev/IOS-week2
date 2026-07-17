//
//  PrimaryButton.swift
//  myapp-1
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var iconName: String? = nil
    var backgroundColor: Color = .blue
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDisabled ? Color.gray : backgroundColor)
                    .shadow(color: (isDisabled ? Color.clear : backgroundColor).opacity(0.4), radius: 5, x: 0, y: 3)
            )
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "Start Game", iconName: "play.fill", action: {})
        PrimaryButton(title: "Disabled", isDisabled: true, action: {})
    }
    .padding()
}
