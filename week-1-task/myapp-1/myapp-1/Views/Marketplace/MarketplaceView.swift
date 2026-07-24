import SwiftUI

struct MarketplaceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    @ObservedObject private var walletService = WalletService.shared
    
    @State private var searchText = ""
    @State private var selectedGameFilter: GameAssociation = .all
    @State private var alertMessage: String? = nil
    
    @State private var previewItem: MarketplaceItem? = nil
    
    // Derived UI Models
    private var allUIItems: [MarketplaceUIWrapper] {
        marketplaceService.catalogue.map { MarketplaceUIHelper.wrap($0) }
    }
    
    private var filteredItems: [MarketplaceUIWrapper] {
        var items = allUIItems
        if selectedGameFilter != .all {
            items = items.filter { $0.game == selectedGameFilter }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.item.name.localizedCaseInsensitiveContains(searchText) }
        }
        return items
    }
    
    private var featuredItems: [MarketplaceUIWrapper] {
        allUIItems.filter { $0.isFeatured }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Search Bar
                        searchBar
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // 2. Featured Carousel
                        if searchText.isEmpty && selectedGameFilter == .all {
                            featuredCarousel
                        }
                        
                        // 3. Category/Game Filters
                        gameFiltersScrollView
                        
                        // 4. Dynamic Sections based on Filter
                        if !filteredItems.isEmpty {
                            if selectedGameFilter == .all && searchText.isEmpty {
                                // Show grouped sections
                                ForEach(GameAssociation.allCases.filter { $0 != .all && $0 != .global }) { game in
                                    gameSection(for: game)
                                }
                                gameSection(for: .global, title: "Cosmetics & Global")
                            } else {
                                // Show grid search results
                                searchResultsGrid
                            }
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Marketplace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Animated Coin Header
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(walletService.wallet.coins)")
                            .font(.system(.headline, design: .rounded, weight: .black))
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: walletService.wallet.coins)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                }
            }
            .alert("Marketplace", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("OK", role: .cancel) { alertMessage = nil }
            } message: {
                Text(alertMessage ?? "")
            }
            .sheet(item: $previewItem) { item in
                MarketplacePreviewSheet(
                    item: item,
                    quantityOwned: marketplaceService.quantity(for: item.id),
                    onPurchase: { handlePurchase(item) }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search items...", text: $searchText)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button {
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var featuredCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Offers")
                .font(.title2)
                .fontWeight(.heavy)
                .padding(.horizontal)
            
            TabView {
                ForEach(featuredItems) { uiItem in
                    Button {
                        previewItem = uiItem.item
                    } label: {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: [uiItem.rarity.color, uiItem.rarity.color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PROMO")
                                        .font(.system(size: 10, weight: .black))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(.white.opacity(0.3)))
                                    
                                    Text(uiItem.item.name)
                                        .font(.title2)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                    
                                    Text(uiItem.item.description)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: uiItem.item.iconName)
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(20)
                        }
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 160)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }
    
    private var gameFiltersScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(GameAssociation.allCases) { game in
                    Button {
                        withAnimation { selectedGameFilter = game }
                    } label: {
                        Text(game.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedGameFilter == game ? game.color : Color(.secondarySystemBackground))
                            )
                            .foregroundColor(selectedGameFilter == game ? .white : AppTheme.Colors.textPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func gameSection(for game: GameAssociation, title: String? = nil) -> some View {
        let items = allUIItems.filter { $0.game == game }
        if items.isEmpty { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 12) {
                Text(title ?? game.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(items) { uiItem in
                            MarketplaceItemCard(
                                item: uiItem.item,
                                quantityOwned: marketplaceService.quantity(for: uiItem.item.id),
                                onPurchase: { previewItem = uiItem.item }
                            )
                            .frame(width: 160)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
        )
    }
    
    private var searchResultsGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredItems) { uiItem in
                MarketplaceItemCard(
                    item: uiItem.item,
                    quantityOwned: marketplaceService.quantity(for: uiItem.item.id),
                    onPurchase: { previewItem = uiItem.item }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No items found.")
                .font(.headline)
            Text("Try a different search term or filter.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
    
    // MARK: - Actions
    
    private func handlePurchase(_ item: MarketplaceItem) {
        if marketplaceService.purchase(item) {
            SoundManager.shared.playBonus()
            alertMessage = "Successfully purchased \(item.name)!"
        } else {
            alertMessage = "Not enough coins to purchase \(item.name)."
        }
    }
}

// Support for Sheet bindings


// MARK: - UI Wrapper Models

enum ItemRarity: String, Comparable {
    case common, rare, epic, legendary
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    static func < (lhs: ItemRarity, rhs: ItemRarity) -> Bool {
        let order: [ItemRarity: Int] = [.common: 0, .rare: 1, .epic: 2, .legendary: 3]
        return order[lhs]! < order[rhs]!
    }
}

enum GameAssociation: String, CaseIterable, Identifiable {
    case all = "All Games"
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    case global = "Global"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .all: return AppTheme.Colors.primary
        case .tapFrenzy: return GameMode.tapFrenzy.color
        case .lightItUp: return GameMode.lightItUp.color
        case .quizRush: return GameMode.quizRush.color
        case .global: return .purple
        }
    }
}

struct MarketplaceUIWrapper: Identifiable {
    let item: MarketplaceItem
    let rarity: ItemRarity
    let game: GameAssociation
    let isFeatured: Bool
    
    var id: String { item.id }
}

class MarketplaceUIHelper {
    static func wrap(_ item: MarketplaceItem) -> MarketplaceUIWrapper {
        let rarity: ItemRarity
        let game: GameAssociation
        var isFeatured = false
        
        switch item.id {
        case "power_double_coins": rarity = .epic; game = .global; isFeatured = true
        case "power_score_shield": rarity = .rare; game = .tapFrenzy
        case "power_time_freezer": rarity = .legendary; game = .global; isFeatured = true
        case "booster_life_refill": rarity = .rare; game = .lightItUp
        case "booster_time_surge": rarity = .rare; game = .tapFrenzy
        case "booster_reveal_answer": rarity = .epic; game = .quizRush
        case "frame_gold": rarity = .legendary; game = .global; isFeatured = true
        case "frame_neon": rarity = .epic; game = .global
        case "frame_galaxy": rarity = .legendary; game = .global
        case "skin_bomb": rarity = .epic; game = .tapFrenzy
        case "skin_lightning": rarity = .legendary; game = .tapFrenzy; isFeatured = true
        case "avatar_brain", "avatar_mustache": rarity = .epic; game = .global
        case "avatar_hare", "avatar_bird": rarity = .rare; game = .global
        default: rarity = .common; game = .global
        }
        
        return MarketplaceUIWrapper(item: item, rarity: rarity, game: game, isFeatured: isFeatured)
    }
}

// MARK: - Preview Sheet

struct MarketplacePreviewSheet: View {
    let item: MarketplaceItem
    let quantityOwned: Int
    let onPurchase: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var walletService = WalletService.shared
    
    private var uiModel: MarketplaceUIWrapper {
        MarketplaceUIHelper.wrap(item)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header: Icon & Glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(gradient: Gradient(colors: [uiModel.rarity.color.opacity(0.8), uiModel.rarity.color.opacity(0.0)]), center: .center, startRadius: 10, endRadius: 100)
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: item.iconName)
                    .font(.system(size: 70))
                    .foregroundColor(.white)
                    .shadow(color: uiModel.rarity.color, radius: 15, x: 0, y: 0)
            }
            .padding(.top, 40)
            
            VStack(spacing: 8) {
                // Rarity & Game Tags
                HStack(spacing: 8) {
                    Text(uiModel.rarity.rawValue.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(uiModel.rarity.color))
                    
                    Text(uiModel.game.rawValue.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(uiModel.game.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().stroke(uiModel.game.color, lineWidth: 2))
                }
                
                Text(item.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.body)
                    .foregroundColor(AppTheme.Colors.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                if !item.isStackable && quantityOwned > 0 {
                    Text("You already own this item.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(Color.gray))
                    }
                } else {
                    if quantityOwned > 0 {
                        Text("Currently Owned: **\(quantityOwned)**")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        onPurchase()
                        dismiss()
                    } label: {
                        HStack {
                            Text("Purchase for")
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text(walletService.wallet.isDeveloperMode ? "FREE" : "\(item.price)")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(walletService.wallet.isDeveloperMode ? Color.red : Color.blue)
                        )
                        .shadow(color: (walletService.wallet.isDeveloperMode ? Color.red : Color.blue).opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}
