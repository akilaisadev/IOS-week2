import SwiftUI

struct CustomArtworkResolver: View {
    let itemId: String
    let iconName: String
    
    var body: some View {
        if itemId == "skin_bomb" {
            BombVectorView()
        } else if itemId == "avatar_tortoise" {
            TortoiseVectorView()
        } else {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
        }
    }
}

// MARK: - Bomb Vector Art
struct BombVectorView: View {
    @State private var fusePhase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let bombRadius = size * 0.35
            
            ZStack {
                // The Fuse
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - bombRadius))
                    path.addQuadCurve(
                        to: CGPoint(x: center.x + size * 0.2, y: center.y - bombRadius - size * 0.25),
                        control: CGPoint(x: center.x + size * 0.2, y: center.y - bombRadius)
                    )
                }
                .stroke(style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round))
                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.4))
                
                // The Fuse Spark
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(.yellow)
                    .offset(x: size * 0.2, y: -bombRadius - size * 0.25)
                    .scaleEffect(1.0 + 0.2 * sin(fusePhase))
                    .rotationEffect(.degrees(Double(fusePhase * 30)))
                    .animation(.linear(duration: 0.5).repeatForever(autoreverses: true), value: fusePhase)
                
                // The Bomb Base (Neck)
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(Color.gray)
                    .frame(width: size * 0.2, height: size * 0.1)
                    .position(x: center.x, y: center.y - bombRadius * 0.95)
                
                // The Bomb Body
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color(white: 0.3), .black]),
                            center: .topLeading,
                            startRadius: size * 0.05,
                            endRadius: size * 0.4
                        )
                    )
                    .frame(width: bombRadius * 2, height: bombRadius * 2)
                    .position(center)
                    
                // Highlight Reflection
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: size * 0.15, height: size * 0.15)
                    .blur(radius: size * 0.03)
                    .position(x: center.x - size * 0.15, y: center.y - size * 0.15)
            }
            .onAppear {
                fusePhase = .pi * 2
            }
        }
        // Force the aspect ratio so it stays square
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Tortoise Vector Art
struct TortoiseVectorView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            
            ZStack {
                // Legs
                ForEach([
                    CGPoint(x: center.x - size * 0.35, y: center.y - size * 0.2), // Top left
                    CGPoint(x: center.x + size * 0.35, y: center.y - size * 0.2), // Top right
                    CGPoint(x: center.x - size * 0.25, y: center.y + size * 0.35), // Bottom left
                    CGPoint(x: center.x + size * 0.25, y: center.y + size * 0.35)  // Bottom right
                ], id: \.x) { pos in
                    Capsule()
                        .fill(Color(red: 0.3, green: 0.7, blue: 0.3))
                        .frame(width: size * 0.2, height: size * 0.15)
                        .rotationEffect(.degrees(pos.x < center.x ? -30 : 30))
                        .position(pos)
                }
                
                // Shell
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.green, Color(red: 0, green: 0.4, blue: 0)]),
                            center: .center,
                            startRadius: size * 0.1,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size * 0.8, height: size * 0.8)
                    .position(center)
                
                // Shell Hexagon Pattern
                Path { path in
                    let radius = size * 0.2
                    for i in 0..<6 {
                        let angle = Double(i) * 60.0 * .pi / 180.0
                        let x = center.x + CGFloat(cos(angle)) * radius
                        let y = center.y + CGFloat(sin(angle)) * radius
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .stroke(Color.green.opacity(0.5), lineWidth: size * 0.03)
                
                // Head
                Circle()
                    .fill(Color(red: 0.4, green: 0.8, blue: 0.4))
                    .frame(width: size * 0.35, height: size * 0.35)
                    .position(x: center.x, y: center.y - size * 0.4)
                
                // Eyes
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.06, height: size * 0.06)
                    .position(x: center.x - size * 0.08, y: center.y - size * 0.45)
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.06, height: size * 0.06)
                    .position(x: center.x + size * 0.08, y: center.y - size * 0.45)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
