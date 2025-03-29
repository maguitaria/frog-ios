//
//  ios_angry_fogApp.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.3.2025.
//

import SwiftUI
import CoreLocation

@main
struct AngryFrogApp: App {
    var body: some Scene {
        WindowGroup {
            AppEntry()
        }
    }
}

struct AppEntry: View {
    @State private var showMainView = false

    var body: some View {
        if showMainView {
            MainTabView()
        } else {
            LoadingView(showMainView: $showMainView)
        }
    }
}
