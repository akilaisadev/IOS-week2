//
//  MarketplaceView.swift
//  myapp-1
//

import SwiftUI

struct MarketplaceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    @ObservedObject private var walletService = WalletService.shared
    
    @State private var selectedCategory: MarketplaceCategory = .powerUps
    @State private var alertMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: 16) {
                    WalletHeaderView()
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(MarketplaceCategory.allCases) { category in
                                Button {
                                    withAnimation { selectedCategory = category }
                                } label: {
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.purple : Color(.secondarySystemBackground))
                                        )
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(filteredItems) { item in
                                MarketplaceItemCard(
                                    item: item,
                                    quantityOwned: marketplaceService.quantity(for: item.id),
                                    onPurchase: {
                                        handlePurchase(item)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Marketplace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
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
        }
    }
    
    private var filteredItems: [MarketplaceItem] {
        marketplaceService.catalogue.filter { $0.category == selectedCategory }
    }
    
    private func handlePurchase(_ item: MarketplaceItem) {
        if marketplaceService.purchase(item) {
            SoundManager.shared.playBonus()
            alertMessage = "Successfully purchased \(item.name)!"
        } else {
            alertMessage = "Not enough coins to purchase \(item.name)."
        }
    }
}

#Preview {
    MarketplaceView()
}
