import SwiftUI

struct LightItUpView: View {

    @State private var score = 0
    @State private var activeCard = 4

    var body: some View {

        VStack(spacing: 20) {

            Text("Light It Up")
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack {

                Text("Score: \(score)")
                    .font(.title2)

                Spacer()

                Text("Time: 60")
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
                        .scaleEffect(
                            index == activeCard ? 1.1 : 1.0
                        )
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LightItUpView()
}
