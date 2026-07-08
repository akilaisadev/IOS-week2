//
//  GameOverView.swift
//  myapp-1
//
//  A reusable game over summary card displaying scores and navigation actions.
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    let highScore: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    var onViewHistory: (() -> Void)? = nil
    var mode: GameMode = .tapFrenzy
    
    var body: some View {
        ResultView(
            score: score,
            highScore: highScore,
            mode: mode,
            onPlayAgain: onPlayAgain,
            onHome: onHome,
            onViewHistory: onViewHistory
        )
    }
}

#Preview {
    GameOverView(score: 85, highScore: 120, onPlayAgain: {}, onHome: {})
}
