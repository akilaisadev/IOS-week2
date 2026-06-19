import SwiftUI

struct ContentView: View {

    var body: some View {

        VStack(spacing: 60) {

            Text("Tap Frenzy")
                .font(.largeTitle)

            Text("Score: 0")
                .font(.title)

            Text("Time: 10")
                .font(.title2)

            Button("TAP") {

            }
            .font(.largeTitle)
            .foregroundColor(.white)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .clipShape(Circle())

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
