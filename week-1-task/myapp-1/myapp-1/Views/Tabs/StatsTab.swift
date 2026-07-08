//
//  StatsTab.swift
//  myapp-1
//
//  tab view displaying game statistics and charts
//

import SwiftUI

struct StatsTab: View {
    @ObservedObject private var historyService = HistoryService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Game Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Total Games Played: \(historyService.sessions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Detailed charts will appear here in Phase 5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsTab()
}
