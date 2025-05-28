import SwiftUI

struct MainTabView: View {
    @StateObject var locationManager = LocationHelper()
  
    var body: some View {
       TabView {
           HomeView(locationHelper: locationManager)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
           if let location = locationManager.location {
                         FrogMapView(locationHelper: locationManager, userLocation: location )
                             .tabItem {
                                 Label("Map", systemImage: "map")
                             }
                     } else {
                         ProgressView("Locating...")
                             .tabItem {
                                 Label("Map", systemImage: "map")
                             }
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
