import SwiftUI
import Combine

struct LightItUpView: View {

    @State private var score = 0
    @State private var activeCard = Int.random(in: 0..<9)
    @State private var timeRemaining = 60

    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        VStack(spacing: 20) {

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

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 15
            ) {

                ForEach(0..<9, id: \.self) { index in

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
                                activeCard = Int.random(in: 0..<9)

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
        }
        .padding()
        .onReceive(timer) { _ in

            if timeRemaining > 0 {

                timeRemaining -= 1
                activeCard = Int.random(in: 0..<9)
            }
        }
    }
}

#Preview {
    LightItUpView()
}
