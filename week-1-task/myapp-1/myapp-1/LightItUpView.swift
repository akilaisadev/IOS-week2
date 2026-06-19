import SwiftUI
import Combine

struct LightItUpView: View {

    @State private var score = 0
    @State private var activeCard = 0
    @State private var timeRemaining = 60

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
                                index == activeCard
                                ? Color.blue
                                : Color.gray.opacity(0.3)
                            )
                            .frame(width: 90, height: 90)
                            .scaleEffect(index == activeCard ? 1.1 : 1.0)
                            .onTapGesture {

                                if index == activeCard {

                                    score += 1
                                    activeCard = Int.random(in: 0..<cardCount)

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
                        .font(.system(size: 50))

                    Divider()

                    Text("High Score")
                        .font(.headline)

                    Text("\(highScore)")
                        .font(.title)
                }
                .padding()
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
        .onReceive(timer) { _ in

            if timeRemaining > 0 {

                timeRemaining -= 1
                activeCard = Int.random(in: 0..<cardCount)
            }

            if timeRemaining == 0 {

                if score > highScore {
                    highScore = score
                }
            }
        }
        .onAppear {
            activeCard = Int.random(in: 0..<cardCount)
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 60
        activeCard = Int.random(in: 0..<3)
    }
}

#Preview {
    LightItUpView()
}
