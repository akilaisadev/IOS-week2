import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Tap Frenzy") {
                    TapFrenzyView()
                }

                NavigationLink("Light It Up") {
                    LightItUpView()
                }
            }
        }
    }
}

