//
//  AppComponents.swift
//  myapp-1
//
//  Reusable UI components following the AppTheme guidelines.
//

import SwiftUI

// MARK: - App Button
struct AppButton: View {
    let title: String
    var iconName: String? = nil
    var backgroundColor: Color = AppTheme.Colors.primary
    var isFullWidth: Bool = true
    var isDisabled: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.extraSmall) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, isFullWidth ? 14 : AppTheme.Spacing.medium)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                    .fill(isDisabled ? Color.gray.opacity(0.5) : backgroundColor)
                    .appButtonShadow(color: isDisabled ? .clear : backgroundColor)
            )
        }
        .buttonStyle(AppButtonScaleStyle())
        .disabled(isDisabled)
    }
}

// Custom ButtonStyle for smooth scale on press
struct AppButtonScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - App Card
struct AppCard<Content: View>: View {
    var padding: CGFloat = AppTheme.Spacing.medium
    let content: () -> Content
    
    init(padding: CGFloat = AppTheme.Spacing.medium, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .fill(AppTheme.Colors.secondaryBackground)
                .appCardShadow()
        )
    }
}

// MARK: - App Stat Card
struct AppStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.extraSmall) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
            
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(1)
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                .fill(AppTheme.Colors.secondaryBackground)
                .appCardShadow()
        )
    }
}

// MARK: - App Progress Bar
struct AppProgressBar: View {
    var value: Double
    var total: Double
    var color: Color = AppTheme.Colors.primary
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(AppTheme.Colors.tertiaryBackground)
                    .frame(height: 12)
                
                // Fill
                Capsule()
                    .fill(
                        LinearGradient(colors: [color.opacity(0.7), color], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: max(0, min(CGFloat(value / total) * geometry.size.width, geometry.size.width)), height: 12)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: value)
            }
        }
        .frame(height: 12)
    }
}

// MARK: - App Chip
struct AppChip: View {
    let text: String
    var icon: String? = nil
    var color: Color = AppTheme.Colors.primary
    var isActive: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundColor(isActive ? .white : color)
        .padding(.horizontal, AppTheme.Spacing.small)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isActive ? color : color.opacity(0.15))
        )
    }
}
