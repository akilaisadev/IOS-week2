//
//  TapFrenzyView.swift 
//

import SwiftUI
import Combine

struct TapFrenzyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    @State private var isShowingReadyScreen = true
    @State private var countdownRemaining: Int? = nil
    
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    @State private var comboCount = 0
    @State private var comboMultiplier = 1
    @State private var maxComboAchieved = 1
    @State private var lastTapTime: Date = Date()
    
    @State private var isTrapActive = false
    @State private var trapDuration = 0
    
    @State private var buttonOffset: CGSize = .zero
    @State private var totalTaps = 0
    
    @State private var bonusMessage: String? = nil
    @State private var showingHistory = false
    @State private var hasRecordedHistory = false
    @State private var isShowingTimeSurgePrompt = false
    @State private var hasUsedTimeSurge = false
    
    @State private var hasScoreShield = false
    @StateObject private var powerUpService = PowerUpService.shared
    @StateObject private var marketplaceService = MarketplaceService.shared
    
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AnimatedBackground(colors: [Color.blue.opacity(0.15), Color.cyan.opacity(0.15)])
            
            VStack(spacing: AppTheme.Spacing.small) {
                VStack(spacing: AppTheme.Spacing.extraSmall) {
                    HStack {
                        ScoreView(score: score, multiplier: comboMultiplier)
                        Spacer(minLength: AppTheme.Spacing.small)
                        HighScoreView(highScore: highScore)
                    }
                    
                    TimerView(timeRemaining: timeRemaining, totalTime: 10)
                }
                .padding(.horizontal)
                
                if let message = bonusMessage {
                    Text(message)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, AppTheme.Spacing.small)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text(hasScoreShield ? "🛡️ Score Shield Active!" : "Tap fast! Watch out for RED traps!")
                        .font(.subheadline)
                        .foregroundColor(hasScoreShield ? .blue : AppTheme.Colors.textSecondary)
                        .frame(height: 36)
                }
                
                Spacer(minLength: AppTheme.Spacing.small)
                
                if !isGameOver && !isShowingReadyScreen {
                    BoosterHUDView(boosterID: "booster_time_surge", iconName: "bolt.fill", title: "+5s Surge", color: .purple) {
                        timeRemaining += 5
                        triggerBonusMessage("TIME SURGE! +5s")
                        SoundManager.shared.playBonus()
                    }
                    .padding(.bottom, AppTheme.Spacing.extraSmall)
                }
                
                if !isGameOver {
                    Button(action: handleButtonTap) {
                        TapFrenzyBallView(
                            buttonDiameter: buttonDiameter,
                            isTrapActive: isTrapActive,
                            activeSkinId: marketplaceService.activeTapFrenzySkinId
                        )
                        .scaleEffect(isTrapActive ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonOffset)
                    }
                    .buttonStyle(AppButtonScaleStyle())
                    .offset(buttonOffset)
                    .disabled(isGameOver)
                }
                
                Spacer()
            }
            .padding(.top)
            .blur(radius: (isShowingReadyScreen || countdownRemaining != nil) ? 8 : 0)
            .disabled(isShowingReadyScreen || countdownRemaining != nil)
            
            if isGameOver {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ResultView(
                    score: score,
                    highScore: highScore,
                    mode: .tapFrenzy,
                    onPlayAgain: restartGame,
                    onHome: { dismiss() },
                    onViewHistory: { showingHistory = true }
                )
                .transition(.scale)
            }
            
            if isShowingReadyScreen {
                VStack(spacing: 16) {
                    ReadyPromptView(
                        title: "GET READY!",
                        subtitle: "Tap the circle as fast as you can to chain combos! Watch out for red traps!",
                        iconName: "hand.tap.fill",
                        themeColor: .blue,
                        onReady: {
                            if powerUpService.activePowerUp == .timeFreezer {
                                timeRemaining += 5
                            }
                            if powerUpService.activePowerUp == .scoreShield {
                                hasScoreShield = true
                            }
                            withAnimation {
                                isShowingReadyScreen = false
                                countdownRemaining = 3
                            }
                        }
                    )
                    
                    PowerUpSelectionView()
                }
                .transition(.opacity.combined(with: .scale))
            } else if isShowingTimeSurgePrompt {
                VStack(spacing: 16) {
                    ReadyPromptView(
                        title: "TIME'S UP!",
                        subtitle: "Use a Time Surge to keep playing for +5 seconds?",
                        iconName: "bolt.fill",
                        themeColor: .purple,
                        onReady: {
                            if MarketplaceService.shared.consumeItem(id: "booster_time_surge") {
                                timeRemaining += 5
                                hasUsedTimeSurge = true
                                triggerBonusMessage("TIME SURGE! +5s")
                                SoundManager.shared.playBonus()
                                withAnimation {
                                    isShowingTimeSurgePrompt = false
                                }
                            }
                        }
                    )
                    
                    Button("No Thanks") {
                        withAnimation {
                            isShowingTimeSurgePrompt = false
                            isGameOver = true
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                }
                .transition(.scale)
            } else if let countdown = countdownRemaining {
                CountdownOverlayView(countdown: countdown, themeColor: .blue)
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingHistory = true }) {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistorySheetView(gameType: .tapFrenzy)
        }
        .onReceive(gameTimer) { _ in
            handleTimerTick()
        }
    }
    
    private var buttonDiameter: CGFloat {
        let baseSize: CGFloat = 210
        let shrinkAmount = CGFloat(totalTaps) * 4
        return max(110, baseSize - shrinkAmount)
    }
    
    private func handleButtonTap() {
        guard !isGameOver, !isShowingReadyScreen, countdownRemaining == nil else { return }
        let now = Date()
        
        if isTrapActive {
            if hasScoreShield {
                hasScoreShield = false
                isTrapActive = false
                triggerBonusMessage("SHIELD BLOCKED TRAP!")
                SoundManager.shared.playBonus()
                return
            }
            score = max(0, score - 3)
            comboCount = 0
            comboMultiplier = 1
            isTrapActive = false
            triggerBonusMessage("TRAPPED! -3 PTS")
            SoundManager.shared.playTrap()
            return
        }
        
        totalTaps += 1
        
        // Check time elapsed since last tap for combo chain
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)
        if timeSinceLastTap < 0.6 {
            comboCount += 1
            comboMultiplier = min(1 + (comboCount / 3), 5)
            if comboMultiplier > maxComboAchieved {
                maxComboAchieved = comboMultiplier
            }
        } else {
            comboCount = 1
            comboMultiplier = 1
        }
        lastTapTime = now
        
        score += 1 * comboMultiplier
        
        if totalTaps % 10 == 0 {
            score += 5
            timeRemaining += 1
            triggerBonusMessage("BONUS BURST! +5 PTS & +1s!")
            SoundManager.shared.playBonus()
        } else if comboMultiplier > 1 {
            SoundManager.shared.playCombo(multiplier: comboMultiplier)
        } else {
            SoundManager.shared.playTap()
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            buttonOffset = CGSize(
                width: CGFloat.random(in: -90...90),
                height: CGFloat.random(in: -100...100)
            )
        }
    }
    
    private func handleTimerTick() {
        guard !isGameOver, !isShowingReadyScreen else { return }
        
        if let countdown = countdownRemaining {
            if countdown > 0 {
                withAnimation {
                    countdownRemaining = countdown - 1
                }
            } else {
                withAnimation {
                    countdownRemaining = nil
                }
            }
            return
        }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        
        if timeRemaining == 0 {
            if !hasUsedTimeSurge && MarketplaceService.shared.quantity(for: "booster_time_surge") > 0 {
                withAnimation {
                    isShowingTimeSurgePrompt = true
                }
                return
            }
            
            withAnimation {
                isGameOver = true
            }
            SoundManager.shared.playGameOver()
            if score > highScore {
                highScore = score
            }
            if !hasRecordedHistory {
                hasRecordedHistory = true
                HistoryService.shared.addSession(
                    mode: .tapFrenzy,
                    score: score,
                    latitude: LocationService.shared.currentLatitude,
                    longitude: LocationService.shared.currentLongitude
                )
            }
            return
        }
        
        if isTrapActive {
            trapDuration -= 1
            if trapDuration <= 0 {
                withAnimation { isTrapActive = false }
            }
        } else {
            if Int.random(in: 1...10) <= 3 && timeRemaining > 2 {
                withAnimation {
                    isTrapActive = true
                    trapDuration = Int.random(in: 1...2)
                }
            }
        }
    }
    
    private func triggerBonusMessage(_ text: String) {
        withAnimation {
            bonusMessage = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                if bonusMessage == text {
                    bonusMessage = nil
                }
            }
        }
    }
    
    private func restartGame() {
        score = 0
        timeRemaining = 10
        totalTaps = 0
        comboCount = 0
        comboMultiplier = 1
        maxComboAchieved = 1
        isTrapActive = false
        buttonOffset = .zero
        bonusMessage = nil
        hasRecordedHistory = false
        withAnimation {
            isGameOver = false
            countdownRemaining = nil
            isShowingReadyScreen = true
        }
    }
}

#Preview {
    NavigationStack {
        TapFrenzyView()
    }
}
