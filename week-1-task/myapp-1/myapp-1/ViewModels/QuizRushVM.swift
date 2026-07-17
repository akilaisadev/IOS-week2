//
//  QuizRushVM.swift
//  myapp-1
//

import SwiftUI
import Combine

@MainActor
class QuizRushVM: ObservableObject {
    
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var isGameOver: Bool = false
    
    @Published var selectedAnswer: String? = nil

    @Published var isAnswerCorrect: Bool? = nil
    
    @AppStorage("quizRushHighScore") var highScore = 0
    
    private let service: TriviaService
    
    init(service: TriviaService? = nil) {
        self.service = service ?? .shared
        Task {
            await loadQuestions()
        }
    }
    
    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
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
    
    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        
        selectedAnswer = answer
        let correct = (answer == question.correctAnswer)
        isAnswerCorrect = correct
        
        if correct {
            streak += 1
            let bonus = (streak >= 3) ? 5 : 0
            score += 10 + bonus
        } else {
            score = max(0, score - 5)
            streak = 0
        }
    }
    
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            isAnswerCorrect = nil
        } else {
            isGameOver = true
            if score > highScore {
                highScore = score
            }
        }
    }
    
    func timeOut() {
        guard selectedAnswer == nil else { return }
        selectedAnswer = "TIME'S UP!"
        isAnswerCorrect = false
        score = max(0, score - 5)
        streak = 0
    }
    
    func restartGame() {
        Task {
            await loadQuestions()
        }
    }
}

typealias QuizRushViewModel = QuizRushVM

