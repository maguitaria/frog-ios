import SwiftUI

struct LoadingView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mint, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: animate)

                Text("FrogGuard")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            animate = true
        }
    }
}
