//
//  QuizRushView.swift
//  myapp-1
//
//  Week 3 assignment: MVVM trivia game fetching 10 questions from OpenTDB API,
//  handling loading/error states, answer verification, history logging, and streak tracking.
//

import SwiftUI

struct QuizRushView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = QuizRushViewModel()
    @State private var showingHistory = false
    @State private var hasRecordedHistory = false
    
    var body: some View {
        ZStack {
            AnimatedBackground(colors: [Color.purple.opacity(0.18), Color.indigo.opacity(0.18)])
            mainContent()
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
        .onChange(of: viewModel.isGameOver) { gameOver in
            if gameOver && !hasRecordedHistory {
                hasRecordedHistory = true
                HistoryService.shared.addRecord(
                    gameType: .quizRush,
                    score: viewModel.score,
                    detail: "Max Streak: \(viewModel.streak)"
                )
            }
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
        VStack(spacing: 20) {
            // Header: Score, Streak, High Score
            HStack {
                ScoreView(score: viewModel.score, streak: viewModel.streak)
                Spacer()
                HighScoreView(highScore: viewModel.highScore)
            }
            .padding(.horizontal)
            
            // Question Progress & Category Badge
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(question.category)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.purple)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            
            // Question Card
            VStack(alignment: .leading, spacing: 12) {
                Text(question.questionText)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
            
            // Multiple Choice Answer Options
            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    answerButton(for: answer, correct: question.correctAnswer)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Next Question Button (shown after an answer is picked)
            if viewModel.selectedAnswer != nil {
                PrimaryButton(
                    title: (viewModel.currentIndex + 1 < viewModel.questions.count) ? "Next Question" : "See Results",
                    iconName: "arrow.right",
                    backgroundColor: .purple
                ) {
                    withAnimation {
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
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectAnswer(answer)
            }
        }) {
            HStack {
                Text(answer)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                if viewModel.selectedAnswer != nil {
                    if answer == correct {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if answer == viewModel.selectedAnswer {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(buttonBackgroundColor(for: answer, correct: correct))
            .foregroundColor(buttonTextColor(for: answer, correct: correct))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .disabled(viewModel.selectedAnswer != nil)
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
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
