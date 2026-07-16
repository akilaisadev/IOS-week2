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
    @State private var errorMessage: String? = nil
    
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
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Gamer Tag (2-16 chars)", text: $inputName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: inputName) { _, newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && (trimmed.count < 2 || trimmed.count > 16) {
                                withAnimation { errorMessage = "Name must be 2-16 characters" }
                            } else {
                                withAnimation { errorMessage = nil }
                            }
                        }
                    
                    if let error = errorMessage {
                        HStack(spacing: 5) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal)
                
                Button {
                    let trimmed = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty || trimmed.count < 2 || trimmed.count > 16 {
                        withAnimation { errorMessage = "Please enter a valid name (2-16 chars)" }
                        return
                    }
                    playerName = trimmed
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
