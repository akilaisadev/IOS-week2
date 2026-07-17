//
//  LightItUpVM.swift
//  myapp-1
//

import SwiftUI
import Combine

class LightItUpVM: ObservableObject {
    @Published var score = 0
    @Published var lives = 3
    @Published var timeRemaining = 60
    @Published var isGameOver = false
    @Published var currentLevel = 1
    @Published var activeCards: Set<Int> = []
    
    func resetGame(duration: Int) {
        score = 0
        lives = 3
        timeRemaining = duration
        isGameOver = false
        currentLevel = 1
        activeCards.removeAll()
    }
}
