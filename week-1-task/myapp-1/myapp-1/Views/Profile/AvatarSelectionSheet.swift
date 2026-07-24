//
//  AvatarSelectionSheet.swift
//  myapp-1
//

import SwiftUI

struct AvatarSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                if availableAvatars.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Avatars Owned")
                            .font(.headline)
                        Text("Visit the marketplace to unlock new avatars with your GameCoins!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                            ForEach(availableAvatars) { item in
                                let isSelected = (marketplaceService.activeAvatarId == item.iconName)
                                
                                Button {
                                    marketplaceService.activeAvatarId = item.iconName
                                    dismiss()
                                } label: {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(isSelected ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: item.iconName)
                                                .font(.system(size: 30))
                                                .foregroundColor(isSelected ? .blue : .primary)
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                                        )
                                        
                                        Text(item.name)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var availableAvatars: [MarketplaceItem] {
        marketplaceService.catalogue
            .filter { $0.category == .avatars && marketplaceService.quantity(for: $0.id) > 0 }
    }
}
