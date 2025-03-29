import SwiftUI

struct LoadingView: View {
    @Binding var showMainView: Bool
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            Image("loading-frog")
                .resizable()
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)

            Text("Angry Frog")
                .font(.title)
                .bold()

            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showMainView = true
            }
        }
    }
}
