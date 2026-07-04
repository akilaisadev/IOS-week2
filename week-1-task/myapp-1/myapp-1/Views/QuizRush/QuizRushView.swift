//
//  QuizRushView.swift
//  myapp-1
//
//  Week 3 assignment: MVVM trivia game fetching 10 questions from OpenTDB API,
//  handling loading/error states, answer verification, history logging, and streak tracking.
//

import SwiftUI
import Combine

struct QuizRushView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = QuizRushViewModel()
    @State private var showingHistory = false
    @State private var hasRecordedHistory = false
    
    // Timer & creative card effect states
    @State private var timeRemaining = 15
    @State private var shakeOffset: CGFloat = 0
    @State private var cardScale: CGFloat = 1.0
    @State private var cardRotation: Double = 0
    @State private var flashColor: Color = .clear
    @State private var streakBanner: String? = nil
    
    // Timer firing every 1 second for question countdown
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AnimatedBackground(colors: [Color.purple.opacity(0.18), Color.indigo.opacity(0.18)])
            mainContent()
            
            flashColor.opacity(0.35)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingHistory = true }) {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistorySheetView(gameType: .quizRush)
        }
        .onChange(of: viewModel.isGameOver) { _, gameOver in
            if gameOver && !hasRecordedHistory {
                hasRecordedHistory = true
                HistoryService.shared.addRecord(
                    gameType: .quizRush,
                    score: viewModel.score,
                    detail: "Max Streak: \(viewModel.streak)"
                )
            }
        }
        .onChange(of: viewModel.currentIndex) { _, _ in
            resetQuestionState()
        }
        .onChange(of: viewModel.isLoading) { _, loading in
            if !loading {
                resetQuestionState()
            }
        }
        .onReceive(gameTimer) { _ in
            handleTimerTick()
        }
    }
    
    private func resetQuestionState() {
        timeRemaining = 15
        streakBanner = nil
        cardRotation = 90
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            cardScale = 1.0
            cardRotation = 0
        }
    }
    
    private func handleTimerTick() {
        guard !viewModel.isLoading, viewModel.errorMessage == nil, !viewModel.isGameOver, viewModel.selectedAnswer == nil else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        
        if timeRemaining == 0 {
            // Time expired!
            viewModel.timeOut()
            triggerShake()
            triggerFlash(.red)
            triggerStreakBanner("⏰ TIME'S UP! -5 PTS")
        }
    }
    
    // Clean ViewBuilder breaking up the conditional view branches for fast compiler type checking
    @ViewBuilder
    private func mainContent() -> some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else if viewModel.isGameOver {
            gameOverView
        } else if let question = viewModel.currentQuestion {
            gameplayView(for: question)
        } else {
            EmptyView()
        }
    }
    
    // Loading State View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.6)
            Text("Fetching Trivia Questions...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // Error State View with Retry action
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Connection Issue")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            PrimaryButton(title: "Retry", iconName: "arrow.clockwise", backgroundColor: .purple) {
                hasRecordedHistory = false
                viewModel.restartGame()
            }
            .frame(width: 200)
        }
        .padding()
    }
    
    // Active Gameplay View for current question
    private func gameplayView(for question: TriviaQuestion) -> some View {
        VStack(spacing: 18) {
            // Header: Score, Streak, High Score, Timer, Level Badge
            VStack(spacing: 12) {
                HStack {
                    ScoreView(score: viewModel.score, streak: viewModel.streak)
                    Spacer()
                    HighScoreView(highScore: viewModel.highScore)
                }
                
                HStack(spacing: 12) {
                    TimerView(timeRemaining: timeRemaining, totalTime: 15)
                    
                    LevelBadge(
                        levelText: "Q\(viewModel.currentIndex + 1)/\(viewModel.questions.count)",
                        badgeColor: .purple
                    )
                }
            }
            .padding(.horizontal)
            
            // Streak or Status Banner
            if let banner = streakBanner {
                Text(banner)
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(banner.contains("🔥") || banner.contains("⚡️") ? Color.orange : Color.red)
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                    )
                    .transition(.scale.combined(with: .opacity))
            } else if let selected = viewModel.selectedAnswer, selected == "⏰ TIME'S UP!" {
                Text("⏰ TIME EXPIRED! -5 PTS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.9))
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Category Tag
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text(question.category.uppercased())
                        .font(.caption)
                        .fontWeight(.heavy)
                        .tracking(1.0)
                        .foregroundColor(.purple)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(height: 24)
            }
            
            // Question Card with Creative Effects
            VStack(alignment: .leading, spacing: 14) {
                Text(question.questionText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: cardShadowColor, radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(cardBorderColor, lineWidth: 2.5)
            )
            .scaleEffect(cardScale)
            .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
            .offset(x: shakeOffset)
            .padding(.horizontal)
            
            // Multiple Choice Answer Options
            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    answerButton(for: answer, correct: question.correctAnswer)
                        .offset(x: shakeOffset)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Next Question Button (shown after an answer is picked or timeout)
            if viewModel.selectedAnswer != nil {
                PrimaryButton(
                    title: (viewModel.currentIndex + 1 < viewModel.questions.count) ? "Next Question" : "See Results",
                    iconName: "arrow.right",
                    backgroundColor: .purple
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        cardScale = 0.95
                        viewModel.nextQuestion()
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.top)
    }
    
    // Individual answer button builder
    private func answerButton(for answer: String, correct: String) -> some View {
        let isSelected = (answer == viewModel.selectedAnswer)
        let isCorrectAnswer = (answer == correct)
        let hasAnswered = (viewModel.selectedAnswer != nil)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                viewModel.selectAnswer(answer)
            }
            
            if answer == correct {
                // Correct answer effects!
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    cardScale = 1.04
                }
                triggerFlash(.green)
                
                if viewModel.streak >= 3 {
                    triggerStreakBanner("🔥 \(viewModel.streak)x STREAK! +15 PTS!")
                } else if viewModel.streak == 2 {
                    triggerStreakBanner("⚡️ 2x STREAK! +10 PTS!")
                }
            } else {
                // Wrong answer effects!
                triggerShake()
                triggerFlash(.red)
                triggerStreakBanner("💥 WRONG ANSWER! -5 PTS")
            }
        }) {
            HStack {
                Text(answer)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                if hasAnswered {
                    if isCorrectAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(buttonBackgroundColor(for: answer, correct: correct))
            .foregroundColor(buttonTextColor(for: answer, correct: correct))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(buttonBorderColor(for: answer, correct: correct), lineWidth: isSelected || (hasAnswered && isCorrectAnswer) ? 2.5 : 1)
            )
            .shadow(color: buttonShadowColor(for: answer, correct: correct), radius: isSelected || (hasAnswered && isCorrectAnswer) ? 8 : 3, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: hasAnswered)
        }
        .disabled(hasAnswered)
    }
    
    // Game Over / Results Summary
    private var gameOverView: some View {
        GameOverView(
            score: viewModel.score,
            highScore: viewModel.highScore,
            onPlayAgain: {
                hasRecordedHistory = false
                viewModel.restartGame()
            },
            onHome: { dismiss() },
            onViewHistory: { showingHistory = true }
        )
    }
    
    private func buttonBackgroundColor(for answer: String, correct: String) -> Color {
        guard let selected = viewModel.selectedAnswer else {
            return Color(.systemBackground)
        }
        if answer == correct {
            return Color.green.opacity(0.25)
        } else if answer == selected {
            return Color.red.opacity(0.25)
        } else {
            return Color(.systemBackground).opacity(0.6)
        }
    }
    
    private func buttonTextColor(for answer: String, correct: String) -> Color {
        guard let selected = viewModel.selectedAnswer else {
            return .primary
        }
        if answer == correct {
            return .green
        } else if answer == selected {
            return .red
        } else {
            return .secondary
        }
    }
    
    private func buttonBorderColor(for answer: String, correct: String) -> Color {
        guard let selected = viewModel.selectedAnswer else {
            return Color.gray.opacity(0.2)
        }
        if answer == correct {
            return .green
        } else if answer == selected {
            return .red
        } else {
            return Color.clear
        }
    }
    
    private func buttonShadowColor(for answer: String, correct: String) -> Color {
        guard let selected = viewModel.selectedAnswer else {
            return Color.black.opacity(0.05)
        }
        if answer == correct {
            return Color.green.opacity(0.35)
        } else if answer == selected {
            return Color.red.opacity(0.35)
        } else {
            return Color.clear
        }
    }
    
    private var cardBorderColor: Color {
        guard let selected = viewModel.selectedAnswer else {
            return Color.purple.opacity(0.35)
        }
        if selected == "⏰ TIME'S UP!" {
            return .red
        }
        return viewModel.isAnswerCorrect == true ? .green : .red
    }
    
    private var cardShadowColor: Color {
        guard let selected = viewModel.selectedAnswer else {
            return Color.purple.opacity(0.12)
        }
        if selected == "⏰ TIME'S UP!" {
            return Color.red.opacity(0.4)
        }
        return viewModel.isAnswerCorrect == true ? Color.green.opacity(0.45) : Color.red.opacity(0.4)
    }
    
    private func triggerShake() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2, blendDuration: 0)) {
            shakeOffset = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.2, blendDuration: 0)) {
                shakeOffset = 0
            }
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
    
    private func triggerStreakBanner(_ text: String) {
        withAnimation {
            streakBanner = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                if streakBanner == text {
                    streakBanner = nil
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
