import SwiftUI

struct LightItUpView: View {

    var body: some View {

        VStack(spacing: 20) {

            Text("Light It Up")
                .font(.largeTitle)

            Text("Score: 0")
                .font(.title2)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 15
            ) {

                ForEach(0..<9, id: \.self) { _ in

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 90, height: 90)
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
