//
//  PlayerProfileSection.swift
//  myapp-1
//

import SwiftUI

enum SaveStatus: Equatable {
    case idle, saving, saved, error(String)
}

struct PlayerProfileSection: View {
    @AppStorage("playerName") private var playerName = "Player 1"
    
    @State private var inputTag = ""
    @State private var saveStatus: SaveStatus = .idle
    @State private var saveTask: DispatchWorkItem? = nil
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                TextField("Gamer Tag (2-16 chars)", text: $inputTag)
                    .onChange(of: inputTag) { _, newValue in
                        // auto save on type
                        validateAndSave(newValue)
                    }
                    .onSubmit {
                        forceSaveOnExit()
                    }
                
                if case .saving = saveStatus {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.75)
                        Text("Saving...")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else if case .saved = saveStatus {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Saved instantly")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .transition(.opacity.combined(with: .scale))
                } else if case .error(let msg) = saveStatus {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: saveStatus)
            .onAppear {
                inputTag = playerName
            }
            .onDisappear {
                forceSaveOnExit()
            }
        } header: {
            Text("Player Profile")
        } footer: {
            Text("Your gamer tag is shown on your home dashboard and shared high score cards.")
        }
    }
    
    private func validateAndSave(_ tag: String) {
        saveTask?.cancel()
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            withAnimation { saveStatus = .error("Name cannot be empty") }
            return
        }
        guard trimmed.count >= 2 else {
            withAnimation { saveStatus = .error("Name must be at least 2 characters") }
            return
        }
        guard trimmed.count <= 16 else {
            withAnimation { saveStatus = .error("Maximum 16 characters allowed") }
            return
        }
        
        withAnimation { saveStatus = .saving }
        
        let workItem = DispatchWorkItem {
            playerName = trimmed
            withAnimation { saveStatus = .saved }
        }
        saveTask = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
    
    private func forceSaveOnExit() {
        saveTask?.cancel()
        let trimmed = inputTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 2 && trimmed.count <= 16 {
            playerName = trimmed
        } else if !playerName.isEmpty && playerName.count >= 2 && playerName.count <= 16 {
            inputTag = playerName
        } else {
            playerName = "Player 1"
            inputTag = "Player 1"
        }
        withAnimation { saveStatus = .idle }
    }
}
