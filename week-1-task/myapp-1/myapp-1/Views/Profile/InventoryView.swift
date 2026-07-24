import SwiftUI

struct InventoryView: View {
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    @State private var selectedCategory: MarketplaceCategory = .avatars
    
    let categories: [MarketplaceCategory] = [.avatars, .skins, .cosmetics]
    
    var body: some View {
        VStack(spacing: 0) {
            // Category picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.small) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation {
                                selectedCategory = category
                            }
                        } label: {
                            Text(categoryTitle(for: category))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(selectedCategory == category ? .white : AppTheme.Colors.textSecondary)
                                .padding(.horizontal, AppTheme.Spacing.medium)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == category ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
                                )
                                .shadow(color: selectedCategory == category ? AppTheme.Colors.primary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, AppTheme.Spacing.small)
            }
            .background(Color(.systemBackground))
            
            // Grid of items
            ScrollView {
                let items = filteredItems
                if items.isEmpty {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        Image(systemName: "bag.fill.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text("No Items Here")
                            .font(.title2.bold())
                        Text("Visit the Marketplace to unlock more customizations!")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: AppTheme.Spacing.small)], spacing: AppTheme.Spacing.small) {
                        ForEach(items) { item in
                            InventoryItemCard(item: item, isActive: isActive(item: item)) {
                                equip(item: item)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.Colors.background)
        }
        .navigationTitle("My Inventory")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredItems: [MarketplaceItem] {
        marketplaceService.catalogue
            .filter { $0.category == selectedCategory && marketplaceService.quantity(for: $0.id) > 0 }
    }
    
    private func categoryTitle(for category: MarketplaceCategory) -> String {
        switch category {
        case .avatars: return "Avatars"
        case .skins: return "Game Skins"
        case .cosmetics: return "Profile Frames"
        default: return ""
        }
    }
    
    private func isActive(item: MarketplaceItem) -> Bool {
        switch item.category {
        case .avatars:
            return marketplaceService.activeAvatarId == item.id
        case .skins:
            return marketplaceService.activeTapFrenzySkinId == item.id
        case .cosmetics:
            return marketplaceService.activeFrameId == item.id
        default:
            return false
        }
    }
    
    private func equip(item: MarketplaceItem) {
        withAnimation {
            switch item.category {
            case .avatars:
                marketplaceService.activeAvatarId = item.id
            case .skins:
                marketplaceService.activeTapFrenzySkinId = item.id
            case .cosmetics:
                marketplaceService.activeFrameId = item.id
            default:
                break
            }
        }
    }
}

struct InventoryItemCard: View {
    let item: MarketplaceItem
    let isActive: Bool
    let onEquip: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                    .fill(isActive ? AppTheme.Colors.primary.opacity(0.15) : AppTheme.Colors.secondaryBackground)
                    .frame(height: 100)
                
                CustomArtworkResolver(itemId: item.id, iconName: item.iconName)
                    .frame(width: 40, height: 40)
                    .foregroundColor(isActive ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                    .stroke(isActive ? AppTheme.Colors.primary : Color.clear, lineWidth: 3)
            )
            
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            
            Button(action: onEquip) {
                Text(isActive ? "EQUIPPED" : "EQUIP")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isActive ? AppTheme.Colors.primary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isActive ? AppTheme.Colors.primary.opacity(0.15) : Color.blue)
                    .clipShape(Capsule())
            }
            .disabled(isActive)
        }
        .padding(AppTheme.Spacing.small)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .appCardShadow()
    }
}
