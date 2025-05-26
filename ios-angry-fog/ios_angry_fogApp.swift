import SwiftUI

@main
struct ios_angry_fogApp: App {
    @State private var showMainTab = false

    var body: some Scene {
        WindowGroup {
            if showMainTab {
                MainTabView()
            } else {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showMainTab = true
                            }
                        }
                    }
            }
        }
    }
}
