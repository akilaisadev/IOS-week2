//
//  TriviaService.swift
//  myapp-1
//
//  Service responsible for asynchronously fetching trivia questions from OpenTDB API.
//

import Foundation

enum TriviaServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL format is invalid."
        case .networkError(let error):
            return "Network connection failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received invalid data from the server."
        case .decodingError:
            return "Failed to process the trivia data."
        }
    }
}

class TriviaService {
    static let shared = TriviaService()
    
    private let endpointURL = "https://opentdb.com/api.php?amount=10&type=multiple"
    
    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: endpointURL) else {
            throw TriviaServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TriviaServiceError.invalidResponse
            }
            
            let apiResponse = try JSONDecoder().decode(TriviaAPIResponse.self, from: data)
            
            return apiResponse.results.map { TriviaQuestion(from: $0) }
        } catch let decodingError as DecodingError {
            throw TriviaServiceError.decodingError(decodingError)
        } catch {
            throw TriviaServiceError.networkError(error)
        }
    }
}
