import SwiftUI

struct ReviveOverlayView: View {
    let requiredBoosterID: String
    let boosterName: String
    let boosterIcon: String
    let boosterColor: Color
    
    let onRevive: () -> Void
    let onSkip: () -> Void
    
    @State private var countdown: Int = 5
    @State private var timer: Timer? = nil
    
    @ObservedObject private var marketplaceService = MarketplaceService.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.large) {
                Text("GAME OVER?")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(countdown) / 5.0)
                        .stroke(boosterColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: countdown)
                    
                    Text("\(countdown)")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text("Keep playing and save your score!")
                    .font(.headline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                let owned = marketplaceService.quantity(for: requiredBoosterID)
                
                if owned > 0 {
                    Button(action: {
                        if marketplaceService.consumeItem(id: requiredBoosterID) {
                            stopTimer()
                            onRevive()
                        }
                    }) {
                        HStack {
                            Image(systemName: boosterIcon)
                            Text("Use \(boosterName)")
                            Spacer()
                            Text("\(owned) left")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(boosterColor)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
                        .appCardShadow()
                    }
                } else {
                    Button(action: {
                        // Inline purchase using coins
                        if let item = marketplaceService.catalogue.first(where: { $0.id == requiredBoosterID }) {
                            if marketplaceService.purchase(item) {
                                if marketplaceService.consumeItem(id: requiredBoosterID) {
                                    stopTimer()
                                    onRevive()
                                }
                            } else {
                                // Not enough coins, skip
                                stopTimer()
                                onSkip()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: boosterIcon)
                            Text("Buy \(boosterName)")
                            Spacer()
                            if let item = marketplaceService.catalogue.first(where: { $0.id == requiredBoosterID }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "dollarsign.circle.fill")
                                    Text("\(item.price)")
                                }
                                .foregroundColor(.yellow)
                            }
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
                        .appCardShadow()
                    }
                }
                
                Button(action: {
                    stopTimer()
                    onSkip()
                }) {
                    Text("No thanks")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                stopTimer()
                onSkip()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
