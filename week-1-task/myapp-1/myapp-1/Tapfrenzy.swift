import SwiftUI
import Combine

struct TapFrenzyView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var highScore = 0

    static let timer = Timer.publish(
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
                .frame(width: 250)
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
        .onReceive(Self.timer) { _ in

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
    TapFrenzyView()
}
