import SwiftUI
import CoreLocation

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            MapView()
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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
