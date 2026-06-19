import SwiftUI
import Combine

struct LightItUpView: View {

    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var activeCards: Set<Int> = []

    @AppStorage("lightItUpHighScore")
    private var highScore = 0

    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var cardCount: Int {

        if timeRemaining > 45 {
            return 3
        } else if timeRemaining > 30 {
            return 4
        } else if timeRemaining > 15 {
            return 6
        } else {
            return 9
        }
    }

    var levelName: String {

        if timeRemaining > 45 {
            return "Level 1"
        } else if timeRemaining > 30 {
            return "Level 2"
        } else if timeRemaining > 15 {
            return "Level 3"
        } else {
            return "Level 4"
        }
    }

    var body: some View {

        VStack(spacing: 20) {

            if timeRemaining > 0 {

                Text("Light It Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {

                    Text("Score: \(score)")
                        .font(.title2)

                    Spacer()

                    Text("Time: \(timeRemaining)")
                        .font(.title2)
                }
                .padding(.horizontal)

                Text(levelName)
                    .font(.headline)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 15
                ) {

                    ForEach(0..<cardCount, id: \.self) { index in

                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                activeCards.contains(index)
                                ? Color.blue
                                : Color.gray.opacity(0.3)
                            )
                            .frame(width: 90, height: 90)
                            .scaleEffect(
                                activeCards.contains(index)
                                ? 1.1
                                : 1.0
                            )
                            .animation(.easeInOut, value: activeCards)
                            .onTapGesture {

                                if activeCards.contains(index) {

                                    score += 1
                                    generateActiveCards()

                                } else {

                                    score -= 1

                                    if score < 0 {
                                        score = 0
                                    }
                                }
                            }
                    }
                }

                Spacer()

            } else {

                Text("Game Over")
                    .font(.largeTitle)

                VStack(spacing: 15) {

                    Text("Results")
                        .font(.title)

                    Text("Final Score")
                        .font(.headline)

                    Text("\(score)")
                        .font(.system(size: 50, weight: .bold))

                    Divider()

                    Text("High Score")
                        .font(.headline)

                    Text("\(highScore)")
                        .font(.title)
                }
                .padding()
                .frame(width: 280)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(20)

                Button("Play Again") {
                    restartGame()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            }
        }
        .padding()
        .onAppear {
            generateActiveCards()
        }
        .onReceive(timer) { _ in

            if timeRemaining > 0 {

                timeRemaining -= 1
                generateActiveCards()
            }

            if timeRemaining == 0 {

                if score > highScore {
                    highScore = score
                }
            }
        }
    }

    func generateActiveCards() {

        if timeRemaining > 15 {

            activeCards = [
                Int.random(in: 0..<cardCount)
            ]

        } else {

            var cards: Set<Int> = []

            while cards.count < 2 {
                cards.insert(Int.random(in: 0..<cardCount))
            }

            activeCards = cards
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 60
        generateActiveCards()
    }
}

#Preview {
    LightItUpView()
}
