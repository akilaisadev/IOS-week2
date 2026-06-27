import SwiftUI

struct ContentView: View {

    var body: some View {

        NavigationStack {

            VStack(spacing: 30) {

                Text("Mini Games")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                NavigationLink {

                    TapFrenzyView()

                } label: {

                    Text("Tap Frenzy")
                        .frame(width: 220, height: 60)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {

                    LightItUpView()

                } label: {

                    Text("Light It Up")
                        .frame(width: 220, height: 60)
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink {

                    QuizRushView()

                } label: {

                    Text("Quiz Rush")
                        .frame(width: 220, height: 60)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
