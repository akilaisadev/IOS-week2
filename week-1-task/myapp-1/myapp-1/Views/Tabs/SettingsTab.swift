//
//  SettingsTab.swift
//  myapp-1
//
//  tab view for application settings and preferences
//

import SwiftUI

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: 20) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("App Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Preferences and audio controls will appear here in Phase 7")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTab()
}
