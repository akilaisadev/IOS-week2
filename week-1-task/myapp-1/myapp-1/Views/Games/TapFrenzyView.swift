//
//  TapFrenzyView.swift
//  myapp-1
//
//  Week 1 assignment: Fast-paced reflex game with 10-second timer, combo multipliers,
//  traps, moving targets, shrinking button size, bonus bursts, and dedicated session history.
//

import SwiftUI
import Combine

struct TapFrenzyView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Core game state properties
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    
    // Persist high score specifically for Tap Frenzy
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    // Challenge 1: Combo Multiplier tracking
    @State private var comboCount = 0
    @State private var comboMultiplier = 1
    @State private var maxComboAchieved = 1
    @State private var lastTapTime: Date = Date()
    
    // Challenge 2: Trap Colour state
    @State private var isTrapActive = false
    @State private var trapDuration = 0
    
    // Challenge 3 & 4: Moving & Shrinking Target
    @State private var buttonOffset: CGSize = .zero
    @State private var totalTaps = 0
    
    // Challenge 5: Bonus Burst message display
    @State private var bonusMessage: String? = nil
    
    // History Sheet & recording state
    @State private var showingHistory = false
    @State private var hasRecordedHistory = false
    
    // Timer firing every 1 second for core countdown
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AnimatedBackground(colors: [Color.blue.opacity(0.15), Color.cyan.opacity(0.15)])
            
            VStack(spacing: 20) {
                // Top Header: Score, High Score, and Timer components
                VStack(spacing: 12) {
                    HStack {
                        ScoreView(score: score, multiplier: comboMultiplier)
                        Spacer()
                        HighScoreView(highScore: highScore)
                    }
                    
                    TimerView(timeRemaining: timeRemaining, totalTime: 10)
                }
                .padding(.horizontal)
                
                // Bonus Burst notification text
                if let message = bonusMessage {
                    Text(message)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("Tap fast! Watch out for RED traps!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(height: 36)
                }
                
                Spacer()
                
                // Main Interactive Tap Button
                if !isGameOver {
                    Button(action: handleButtonTap) {
                        VStack(spacing: 4) {
                            Image(systemName: isTrapActive ? "exclamationmark.octagon.fill" : "hand.tap.fill")
                                .font(.system(size: buttonDiameter * 0.25))
                            
                            Text(isTrapActive ? "TRAP!" : "TAP!")
                                .font(.system(size: buttonDiameter * 0.18, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(width: buttonDiameter, height: buttonDiameter)
                        .background(
                            Circle()
                                .fill(isTrapActive ? Color.red : Color.blue)
                                .shadow(color: (isTrapActive ? Color.red : Color.blue).opacity(0.5), radius: 15, x: 0, y: 8)
                        )
                        .scaleEffect(isTrapActive ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonOffset)
                    }
                    .offset(buttonOffset)
                    .disabled(isGameOver)
                }
                
                Spacer()
            }
            .padding(.top)
            
            // Game Over overlay displayed when timer reaches 0
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
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
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
    
    // Calculates dynamic button size based on total taps (Challenge 4)
    private var buttonDiameter: CGFloat {
        let baseSize: CGFloat = 210
        let shrinkAmount = CGFloat(totalTaps) * 4
        return max(110, baseSize - shrinkAmount)
    }
    
    private func handleButtonTap() {
        let now = Date()
        
        // Challenge 2: If tapped while red trap is active, penalize points
        if isTrapActive {
            score = max(0, score - 3)
            comboCount = 0
            comboMultiplier = 1
            isTrapActive = false
            triggerBonusMessage("TRAPPED! -3 PTS")
            SoundManager.shared.playTrap()
            return
        }
        
        totalTaps += 1
        
        // Challenge 1: Check time elapsed since last tap for combo chain
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
        
        // Challenge 5: Every 10 taps awards a bonus burst
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
        
        // Challenge 3: Move button to a random safe position inside the play area
        withAnimation(.easeInOut(duration: 0.2)) {
            buttonOffset = CGSize(
                width: CGFloat.random(in: -90...90),
                height: CGFloat.random(in: -100...100)
            )
        }
    }
    
    private func handleTimerTick() {
        guard !isGameOver else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        
        if timeRemaining == 0 {
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
        }
    }
}

#Preview {
    NavigationStack {
        TapFrenzyView()
    }
}
