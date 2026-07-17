//
//  ContentView.swift
//  myapp-1
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller.fill")
                }
                .tag(0)
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(2)
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
