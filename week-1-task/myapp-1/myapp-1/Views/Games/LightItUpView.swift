//
//  LightItUpView.swift
//  myapp-1
//

import SwiftUI
import Combine

struct LightItUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDuration = 60
    @State private var timeRemaining = 60
    
    @State private var score = 0
    @State private var lives = 3
    @State private var isGameOver = false
    @State private var isShowingReadyScreen = true
    @State private var countdownRemaining: Int? = nil
    @State private var activeCards: Set<Int> = []
    
    @State private var currentLevel = 1
    @State private var maxLevelReached = 1
    @State private var levelUpBanner: String? = nil
    
    @State private var flashColor: Color = .clear
    
    @State private var cardTimeRemaining: Double = 1.5
    @State private var tickCounter = 0
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var showingHistory = false
    @State private var hasRecordedHistory = false
    
    let gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AnimatedBackground(colors: [Color.orange.opacity(0.18), Color.yellow.opacity(0.15)])
            
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    HStack {
                        ScoreView(score: score)
                        Spacer()
                        HighScoreView(highScore: highScore)
                    }
                    
                    TimerView(timeRemaining: Int(ceil(Double(timeRemaining))), totalTime: selectedDuration)
                    
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(1...3, id: \.self) { heart in
                                Image(systemName: heart <= lives ? "heart.fill" : "heart")
                                    .foregroundColor(heart <= lives ? .red : .gray.opacity(0.3))
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color.orange.opacity(0.12), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(levelColor)
                            Text("Level \(currentLevel): \(levelName)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(levelColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(levelColor.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: levelColor.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
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
                
                if !isGameOver {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: gridColumns),
                        spacing: 16
                    ) {
                        ForEach(0..<cardCount, id: \.self) { index in
                            let isLit = activeCards.contains(index)
                            
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isLit ? AnyShapeStyle(levelColor) : AnyShapeStyle(Color(.systemBackground)))
                                .frame(height: cardHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(isLit ? Color.white : Color.orange.opacity(0.25), lineWidth: isLit ? 3 : 1.5)
                                )
                                .shadow(color: isLit ? levelColor.opacity(0.6) : Color.orange.opacity(0.12), radius: isLit ? 12 : 6, x: 0, y: isLit ? 6 : 3)
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
                    .onChange(of: selectedDuration) { _, _ in
                        restartGame()
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.top)
            .blur(radius: (isShowingReadyScreen || countdownRemaining != nil) ? 8 : 0)
            .disabled(isShowingReadyScreen || countdownRemaining != nil)
            
            flashColor.opacity(0.3)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            if isGameOver {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ResultView(
                    score: score,
                    highScore: highScore,
                    mode: .lightItUp,
                    onPlayAgain: restartGame,
                    onHome: { dismiss() },
                    onViewHistory: { showingHistory = true }
                )
            }
            
            if isShowingReadyScreen {
                ReadyPromptView(
                    title: "GET READY!",
                    subtitle: "Memorize and tap the lit target cards before their light expires! Don't tap dark tiles!",
                    iconName: "bolt.fill",
                    themeColor: .orange,
                    onReady: {
                        withAnimation {
                            isShowingReadyScreen = false
                            countdownRemaining = 3
                            tickCounter = 0
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale))
            } else if let countdown = countdownRemaining {
                CountdownOverlayView(countdown: countdown, themeColor: .orange)
            }
        }
        .navigationTitle("Light It Up")
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
            return (1, "Warmup", 3, 1.5, .orange)
        } else if progress < 0.50 {
            return (2, "Accelerate", 4, 1.2, Color(red: 1.0, green: 0.55, blue: 0.15))
        } else if progress < 0.75 {
            return (3, "Overdrive", 6, 1.0, Color(red: 1.0, green: 0.38, blue: 0.28))
        } else {
            return (4, "Frenzy", 9, 0.8, Color(red: 0.96, green: 0.22, blue: 0.32))
        }
    }
    
    private var levelName: String { levelInfo.name }
    private var cardCount: Int { levelInfo.cards }
    private var levelColor: Color { levelInfo.color }
    private var gridColumns: Int { cardCount <= 4 ? 2 : 3 }
    private var cardHeight: CGFloat { cardCount <= 4 ? 120 : 90 }
    
    private func handleCardTap(at index: Int) {
        guard !isGameOver, !isShowingReadyScreen, countdownRemaining == nil else { return }
        
        if activeCards.contains(index) {
            score += 1
            triggerFlash(.green)
            spawnNewLitCards()
            SoundManager.shared.playCardCorrect()
        } else {
            score = max(0, score - 1)
            loseLife(reason: "Wrong Card!")
        }
    }
    
    private func handleTimerTick() {
        guard !isGameOver, !isShowingReadyScreen else { return }
        
        if let countdown = countdownRemaining {
            tickCounter += 1
            if tickCounter % 10 == 0 {
                if countdown > 0 {
                    withAnimation {
                        countdownRemaining = countdown - 1
                    }
                } else {
                    withAnimation {
                        countdownRemaining = nil
                    }
                    spawnNewLitCards()
                }
            }
            return
        }
        
        let newLevel = levelInfo.level
        if newLevel != currentLevel {
            currentLevel = newLevel
            if currentLevel > maxLevelReached {
                maxLevelReached = currentLevel
            }
            triggerLevelUpBanner("LEVEL UP! Level \(currentLevel)")
            SoundManager.shared.playLevelUp()
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
        SoundManager.shared.playGameOver()
        if score > highScore {
            highScore = score
        }
        if !hasRecordedHistory {
            hasRecordedHistory = true
            HistoryService.shared.addSession(
                mode: .lightItUp,
                score: score,
                latitude: LocationService.shared.currentLatitude,
                longitude: LocationService.shared.currentLongitude
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
        } else {
            SoundManager.shared.playCardWrong()
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
            countdownRemaining = nil
            isShowingReadyScreen = true
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
