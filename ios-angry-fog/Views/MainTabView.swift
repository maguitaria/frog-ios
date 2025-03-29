//
//  MainTabView.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 29.3.2025.
//

import SwiftUICore
import SwiftUI


struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
