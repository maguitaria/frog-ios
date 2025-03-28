//
//  ios_angry_fogApp.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.3.2025.
//

import SwiftUI

@main
struct ios_angry_fogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: FrogViewModel())
        }
    }
}
