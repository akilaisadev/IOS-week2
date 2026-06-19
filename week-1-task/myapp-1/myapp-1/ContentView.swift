import SwiftUI

struct ContentView: View {

    @State private var score = 0

    var body: some View {

        VStack(spacing: 30) {

            Text("Tap Frenzy")
                .font(.largeTitle)

            Text("Score: \(score)")
                .font(.title)

            Text("Time: 10")
                .font(.title2)

            Button("TAP") {
                score += 1
            }
            .font(.largeTitle)
            .foregroundColor(.white)
            .frame(width: 200, height: 200)
            .background(Color.blue)
            .clipShape(Circle())

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
