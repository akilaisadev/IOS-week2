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
                    VStack(spacing: AppTheme.Spacing.small) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text("No Avatars Owned")
                            .font(.headline)
                        Text("Visit the marketplace to unlock new avatars with your GameCoins!")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: AppTheme.Spacing.medium) {
                            ForEach(availableAvatars) { item in
                                let isSelected = (marketplaceService.activeAvatarId == item.iconName)
                                
                                Button {
                                    marketplaceService.activeAvatarId = item.iconName
                                    dismiss()
                                } label: {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(isSelected ? AppTheme.Colors.primary.opacity(0.15) : AppTheme.Colors.secondaryBackground)
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: item.iconName)
                                                .font(.system(size: 30))
                                                .foregroundColor(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 3)
                                        )
                                        .shadow(color: isSelected ? AppTheme.Colors.primary.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                                        
                                        Text(item.name)
                                            .font(.caption)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(AppButtonScaleStyle())
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
