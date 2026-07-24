//
//  ContentView.swift
//  myapp-1
//
//  main tab view containing our 4 application tabs
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject private var tabBarManager = TabBarManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $selectedTab) {
                HomeTab()
                    .tag(0)
                
                StatsTab()
                    .tag(1)
                
                MapTab()
                    .tag(2)
                
                SettingsTab()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Swipeable tabs
            
            
            // Custom Floating Tab Bar
            if !TabBarManager.shared.isHidden {
                HStack(spacing: 0) {
                    tabButton(icon: "gamecontroller.fill", title: "Home", tag: 0)
                    tabButton(icon: "chart.bar.fill", title: "Stats", tag: 1)
                    tabButton(icon: "map.fill", title: "Map", tag: 2)
                    tabButton(icon: "gearshape.fill", title: "Settings", tag: 3)
                }
                .padding(.vertical, AppTheme.Spacing.extraSmall)
                .padding(.horizontal, AppTheme.Spacing.small)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.secondaryBackground)
                        .appCardShadow()
                )
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.bottom, 24) // Float above bottom edge
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environmentObject(TabBarManager.shared)
        .onReceive(TabBarManager.shared.$isHidden) { _ in } // Force view update
    }
    
    @ViewBuilder
    private func tabButton(icon: String, title: String, tag: Int) -> some View {
        let isSelected = selectedTab == tag
        
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppTheme.Colors.primaryGradient)
                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: tabAnimationNamespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
    
    @Namespace private var tabAnimationNamespace
}

#Preview {
    ContentView()
}
