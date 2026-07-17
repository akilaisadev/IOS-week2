//
//  TriviaQuestion.swift
//  myapp-1
//

import Foundation

struct TriviaAPIResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestionDTO]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestionDTO: Codable {
    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let category: String
    let difficulty: String
    let questionText: String
    let correctAnswer: String
    let allAnswers: [String]
    
    init(from dto: TriviaQuestionDTO) {
        // fix weird html texts from the api
        self.category = HTMLEntityDecoder.decode(dto.category)
        self.difficulty = dto.difficulty.capitalized
        self.questionText = HTMLEntityDecoder.decode(dto.question)
        self.correctAnswer = HTMLEntityDecoder.decode(dto.correctAnswer)
        
        var decodedAnswers = dto.incorrectAnswers.map { HTMLEntityDecoder.decode($0) }
        decodedAnswers.append(self.correctAnswer)
        self.allAnswers = decodedAnswers.shuffled()
    }
}
