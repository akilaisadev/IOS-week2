import SwiftUI
import Combine

struct ContentView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var highScore = 0

    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        VStack(spacing: 20) {

            if timeRemaining > 0 {

                Text("Tap Frenzy")
                    .font(.largeTitle)

                Text("Score: \(score)")
                    .font(.title)

                Text("Time: \(timeRemaining)")
                    .font(.title2)

                Button("TAP") {
                    score += 1
                }
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 300, height: 300)
                .background(Color.blue)
                .clipShape(Circle())

            } else {

                Text("Game Over")
                    .font(.largeTitle)

                Text("Final Score: \(score)")
                    .font(.title2)

                Text("High Score: \(highScore)")
                    .font(.title3)

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
            }

            if timeRemaining == 0 {

                if score > highScore {
                    highScore = score
                }
            }
        }
    }

    func restartGame() {
        score = 0
        timeRemaining = 10
    }
}

#Preview {
    ContentView()
}
