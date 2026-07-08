//
//  TapFrenzyVM.swift
//  myapp-1
//
//  view model for tap frenzy game state and timers
//

import SwiftUI
import Combine

class TapFrenzyVM: ObservableObject {
    @Published var score = 0
    @Published var timeRemaining = 10
    @Published var isGameOver = false
    @Published var comboCount = 0
    @Published var comboMultiplier = 1
    @Published var isTrapActive = false
    @Published var bonusMessage: String? = nil
    
    // reset game state for a new round
    func resetGame() {
        score = 0
        timeRemaining = 10
        isGameOver = false
        comboCount = 0
        comboMultiplier = 1
        isTrapActive = false
        bonusMessage = nil
    }
}
