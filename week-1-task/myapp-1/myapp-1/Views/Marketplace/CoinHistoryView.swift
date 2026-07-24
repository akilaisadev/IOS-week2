//
//  CoinHistoryView.swift
//  myapp-1
//

import SwiftUI

struct CoinHistoryView: View {
    @ObservedObject private var walletService = WalletService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if walletService.transactions.isEmpty {
                    Text("No coin transactions recorded yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                } else {
                    ForEach(walletService.transactions) { tx in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(tx.isPositive ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: tx.isPositive ? "arrow.down.left" : "arrow.up.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(tx.isPositive ? .green : .red)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tx.reason)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Text(tx.formattedDate)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(tx.isPositive ? "+\(tx.amount)" : "\(tx.amount)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(tx.isPositive ? .green : .red)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle("Coin Ledger")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CoinHistoryView()
    }
}
