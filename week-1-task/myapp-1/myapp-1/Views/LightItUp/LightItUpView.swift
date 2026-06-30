//
//  LightItUpView.swift
//  myapp-1
//
//  Week 2 assignment: Grid reflex game with 4 progressive difficulty levels,
//  level-up animations, flash overlays, duration settings, 3-life system, and session history.
//

import SwiftUI
import Combine

struct LightItUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Configurable game duration options (30, 60, or 90 seconds)
    @State private var selectedDuration = 60
    @State private var timeRemaining = 60
    
    // Core game state
    @State private var score = 0
    @State private var lives = 3
    @State private var isGameOver = false
    @State private var activeCards: Set<Int> = []
    
    // Tracks current level to trigger level-up animations
    @State private var currentLevel = 1
    @State private var maxLevelReached = 1
    @State private var levelUpBanner: String? = nil
    
    // Screen flash animation state
    @State private var flashColor: Color = .clear
    
    // Sub-second timer tracking for individual card light expiration
    @State private var cardTimeRemaining: Double = 1.5
    @State private var tickCounter = 0
    
    // Persist high score specifically for Light It Up
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    // History sheet & recording state
    @State private var showingHistory = false
    @State private var hasRecordedHistory = false
    
    // Timer firing every 0.1 seconds for precise card light timing and countdown
    let gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AnimatedBackground(colors: [levelColor.opacity(0.15), Color.black.opacity(0.8)])
            
            VStack(spacing: 16) {
                // Top header: Score, Lives, High Score
                HStack {
                    ScoreView(score: score)
                    
                    Spacer()
                    
                    // 3-Life System Heart Display
                    HStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { heart in
                            Image(systemName: heart <= lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(radius: 4)
                    
                    Spacer()
                    
                    HighScoreView(highScore: highScore)
                }
                .padding(.horizontal)
                
                // Timer and Level Badge
                HStack {
                    TimerView(timeRemaining: Int(ceil(Double(timeRemaining))), totalTime: selectedDuration)
                    LevelBadge(levelText: "Level \(currentLevel): \(levelName)", badgeColor: levelColor)
                }
                .padding(.horizontal)
                
                // Level-Up Celebration Banner
                if let banner = levelUpBanner {
                    Text(banner)
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(levelColor)
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Interactive Card Grid
                if !isGameOver {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: gridColumns),
                        spacing: 16
                    ) {
                        ForEach(0..<cardCount, id: \.self) { index in
                            let isLit = activeCards.contains(index)
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isLit ? levelColor : Color.gray.opacity(0.25))
                                .frame(height: cardHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isLit ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .shadow(color: isLit ? levelColor.opacity(0.7) : Color.clear, radius: 12, x: 0, y: 4)
                                .scaleEffect(isLit ? 1.05 : 1.0)
                                .animation(.spring(response: 0.25), value: isLit)
                                .onTapGesture {
                                    handleCardTap(at: index)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Duration configuration picker
                HStack {
                    Text("Duration:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Picker("Duration", selection: $selectedDuration) {
                        Text("30s").tag(30)
                        Text("60s").tag(60)
                        Text("90s").tag(90)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                    .onChange(of: selectedDuration) { _ in
                        restartGame()
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.top)
            
            flashColor.opacity(0.3)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // Game Over Screen
            if isGameOver {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                GameOverView(
                    score: score,
                    highScore: highScore,
                    onPlayAgain: restartGame,
                    onHome: { dismiss() },
                    onViewHistory: { showingHistory = true }
                )
                .transition(.scale)
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingHistory = true }) {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistorySheetView(gameType: .lightItUp)
        }
        .onAppear {
            restartGame()
        }
        .onReceive(gameTimer) { _ in
            handleTimerTick()
        }
    }
    
    private var levelInfo: (level: Int, name: String, cards: Int, lightDuration: Double, color: Color) {
        let elapsed = selectedDuration - timeRemaining
        let progress = Double(elapsed) / Double(selectedDuration)
        
        if progress < 0.25 {
            return (1, "Warmup", 3, 1.5, .green)
        } else if progress < 0.50 {
            return (2, "Accelerate", 4, 1.2, .blue)
        } else if progress < 0.75 {
            return (3, "Overdrive", 6, 1.0, .purple)
        } else {
            return (4, "Frenzy", 9, 0.8, .orange)
        }
    }
    
    private var levelName: String { levelInfo.name }
    private var cardCount: Int { levelInfo.cards }
    private var levelColor: Color { levelInfo.color }
    private var gridColumns: Int { cardCount <= 4 ? 2 : 3 }
    private var cardHeight: CGFloat { cardCount <= 4 ? 120 : 90 }
    
    private func handleCardTap(at index: Int) {
        guard !isGameOver else { return }
        
        if activeCards.contains(index) {
            score += 1
            triggerFlash(.green)
            spawnNewLitCards()
        } else {
            score = max(0, score - 1)
            loseLife(reason: "Wrong Card!")
        }
    }
    
    private func handleTimerTick() {
        guard !isGameOver else { return }
        
        let newLevel = levelInfo.level
        if newLevel != currentLevel {
            currentLevel = newLevel
            if currentLevel > maxLevelReached {
                maxLevelReached = currentLevel
            }
            triggerLevelUpBanner("🚀 LEVEL UP! Level \(currentLevel)")
        }
        
        tickCounter += 1
        if tickCounter % 10 == 0 && timeRemaining > 0 {
            timeRemaining = max(0, timeRemaining - 1)
        }
        
        if timeRemaining == 0 {
            triggerGameOver()
            return
        }
        
        cardTimeRemaining -= 0.1
        if cardTimeRemaining <= 0 {
            loseLife(reason: "Time Expired!")
            if !isGameOver {
                spawnNewLitCards()
            }
        }
    }
    
    private func triggerGameOver() {
        withAnimation {
            isGameOver = true
        }
        if score > highScore {
            highScore = score
        }
        if !hasRecordedHistory {
            hasRecordedHistory = true
            HistoryService.shared.addRecord(
                gameType: .lightItUp,
                score: score,
                detail: "Reached Level \(maxLevelReached) (\(selectedDuration)s Mode)"
            )
        }
    }
    
    private func spawnNewLitCards() {
        let info = levelInfo
        cardTimeRemaining = info.lightDuration
        
        var newCards: Set<Int> = []
        let targetLitCount = info.level == 4 ? 2 : 1
        
        while newCards.count < targetLitCount && newCards.count < info.cards {
            newCards.insert(Int.random(in: 0..<info.cards))
        }
        
        activeCards = newCards
    }
    
    private func loseLife(reason: String) {
        lives -= 1
        triggerFlash(.red)
        
        if lives <= 0 {
            triggerGameOver()
        }
    }
    
    private func triggerFlash(_ color: Color) {
        withAnimation(.easeIn(duration: 0.1)) {
            flashColor = color
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.15)) {
                flashColor = .clear
            }
        }
    }
    
    private func triggerLevelUpBanner(_ text: String) {
        withAnimation {
            levelUpBanner = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                if levelUpBanner == text {
                    levelUpBanner = nil
                }
            }
        }
    }
    
    private func restartGame() {
        score = 0
        lives = 3
        timeRemaining = selectedDuration
        tickCounter = 0
        currentLevel = 1
        maxLevelReached = 1
        levelUpBanner = nil
        flashColor = .clear
        hasRecordedHistory = false
        withAnimation {
            isGameOver = false
        }
        spawnNewLitCards()
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
