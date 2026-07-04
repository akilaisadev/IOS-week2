//
//  QuizRushViewModel.swift
//  myapp-1
//
//  ViewModel managing all logic, state, and API fetching for Week 3 Quiz Rush.
//

import SwiftUI
import Combine

@MainActor
class QuizRushViewModel: ObservableObject {
    
    // Published states observed by the View
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var isGameOver: Bool = false
    
    // Tracks current question interaction
    @Published var selectedAnswer: String? = nil
    @Published var isAnswerCorrect: Bool? = nil
    
    // Persist high score specifically for Quiz Rush
    @AppStorage("quizRushHighScore") var highScore = 0
    
    private let service: TriviaService
    
    init(service: TriviaService? = nil) {
        self.service = service ?? .shared
        Task {
            await loadQuestions()
        }
    }
    
    // Current active question
    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    // Asynchronously loads questions from API and resets game state
    func loadQuestions() async {
        isLoading = true
        errorMessage = nil
        isGameOver = false
        score = 0
        streak = 0
        currentIndex = 0
        selectedAnswer = nil
        isAnswerCorrect = nil
        
        do {
            questions = try await service.fetchQuestions()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    // Validates player's selected choice and updates scores/streak
    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        
        selectedAnswer = answer
        let correct = (answer == question.correctAnswer)
        isAnswerCorrect = correct
        
        if correct {
            // Award base points + streak bonus if on a hot streak
            streak += 1
            let bonus = (streak >= 3) ? 5 : 0
            score += 10 + bonus
        } else {
            // Deduct points and reset streak
            score = max(0, score - 5)
            streak = 0
        }
    }
    
    // Transitions to the next question or finishes the game
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            isAnswerCorrect = nil
        } else {
            // Game completed!
            isGameOver = true
            if score > highScore {
                highScore = score
            }
        }
    }
    
    // Handles when question timer expires
    func timeOut() {
        guard selectedAnswer == nil else { return }
        selectedAnswer = "⏰ TIME'S UP!"
        isAnswerCorrect = false
        score = max(0, score - 5)
        streak = 0
    }
    
    // Restarts game by refetching trivia questions
    func restartGame() {
        Task {
            await loadQuestions()
        }
    }
}

