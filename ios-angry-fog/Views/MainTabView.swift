import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FrogMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            ReportView()
                .tabItem {
                    Label("Report", systemImage: "exclamationmark.bubble")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }

            TravelModeView()
                .tabItem {
                    Label("Travel Mode", systemImage: "phone.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
