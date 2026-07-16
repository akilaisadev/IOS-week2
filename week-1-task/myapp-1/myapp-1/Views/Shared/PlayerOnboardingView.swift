//
//  PlayerOnboardingView.swift
//  myapp-1
//
//  Minimal startup sheet prompting for player details on initial launch.
//

import SwiftUI

struct PlayerOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasEnteredPlayerDetails") private var hasEnteredPlayerDetails = false
    @AppStorage("playerName") private var playerName = "Player 1"
    @State private var inputName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 64))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding(.top, 20)
                
                VStack(spacing: 6) {
                    Text("Welcome to GameHub")
                        .font(.title.bold())
                    Text("Enter your gamer tag to personalize your profile and scores across all games.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                TextField("Gamer Tag (e.g. ShadowTap)", text: $inputName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button {
                    let trimmed = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                    playerName = trimmed.isEmpty ? "Player 1" : trimmed
                    hasEnteredPlayerDetails = true
                    dismiss()
                } label: {
                    Text("Save & Play")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Player Setup")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !playerName.isEmpty && playerName != "Player 1" { inputName = playerName }
            }
        }
    }
}
