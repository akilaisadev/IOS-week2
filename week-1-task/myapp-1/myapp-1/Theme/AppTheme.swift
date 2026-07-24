//
//  AppTheme.swift
//  myapp-1
//
//  Global Design System for the app.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primary = Color.purple
        static let secondary = Color.orange
        static let success = Color.green
        static let error = Color.red
        
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        
        // Soft gradients
        static let primaryGradient = LinearGradient(colors: [Color.purple.opacity(0.8), Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        static let secondaryGradient = LinearGradient(colors: [Color.orange.opacity(0.8), Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - Spacing (8-point grid)
    struct Spacing {
        static let extraSmall: CGFloat = 8
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let extraLarge: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    struct Radius {
        static let card: CGFloat = 20
        static let button: CGFloat = 16
        static let chip: CGFloat = 12
        static let dialog: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        // Reduced shadow intensity for premium look
        static func card(color: Color = Color.black) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        
        static func button(color: Color) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        
        static func heavy(color: Color = Color.black) -> ShadowModifier {
            ShadowModifier(color: color.opacity(0.08), radius: 16, x: 0, y: 8)
        }
    }
}

// Helper modifier for standard shadows
struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

extension View {
    func appCardShadow() -> some View {
        self.modifier(AppTheme.Shadows.card())
    }
    
    func appButtonShadow(color: Color = AppTheme.Colors.primary) -> some View {
        self.modifier(AppTheme.Shadows.button(color: color))
    }
}
