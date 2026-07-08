//
//  MapTab.swift
//  myapp-1
//
//  tab view displaying gameplay locations on an interactive map
//

import SwiftUI

struct MapTab: View {
    @ObservedObject private var historyService = HistoryService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: 20) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Gameplay Map")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Recorded Locations: \(historyService.sessions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Interactive map pins will appear here in Phase 6")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Map")
        }
    }
}

#Preview {
    MapTab()
}
