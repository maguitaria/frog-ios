import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var locationHelper = LocationHelper()
    @State private var dashboard: DashboardData?
    @State private var loadingDashboard = true
    @State private var dashboardError: String?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.mint, .blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("🐸 FrogGuard")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .padding(.top)
                    
                    if let location = locationHelper.lastKnownLocation {
                        Text("📍 \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))")
                            .font(.callout)
                    } else {
                        Text("📍 Detecting location...")
                            .foregroundColor(.gray)
                    }
                    
                    if let town = locationHelper.lastKnownTown {
                        Text("🏘 You're in \(town)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    if loadingDashboard {
                        VStack(spacing: 20) {
                            ProgressView("Fetching safety data...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 40)
                    } else if let dashboard = dashboard {
                        VStack(alignment: .leading, spacing: 24) {
                            airQualityCard(dashboard)
                            conflictEventsSection(dashboard)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding()
                    } else if let error = dashboardError {
                        Text("❌ \(error)").foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .onChange(of: locationHelper.lastKnownLocation) { _ in
            fetchDashboard()
        }
    }
    
    func fetchDashboard() {
        guard let location = locationHelper.lastKnownLocation else { return }
        
        loadingDashboard = true
        dashboardError = nil
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/dashboard?lat=\(lat)&lon=\(lon)") else {
            dashboardError = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                loadingDashboard = false
                if let data = data {
                    do {
                        let decoded = try JSONDecoder().decode(DashboardData.self, from: data)
                        dashboard = decoded
                    } catch {
                        dashboardError = "Failed to parse dashboard data"
                        print("❌ Decode error:", error)
                        print("📦 Raw JSON:", String(data: data, encoding: .utf8) ?? "")
                    }
                } else {
                    dashboardError = "Failed to load data"
                }
            }
        }.resume()
    }
    func aqiLabelColor(_ aqi: Int) -> (String, Color) {
        switch aqi {
        case 1: return ("Good", .green)
        case 2: return ("Fair", .yellow)
        case 3: return ("Moderate", .orange)
        case 4: return ("Poor", .red)
        case 5: return ("Very Poor", .purple)
        default: return ("Unknown", .gray)
        }
    }

    @ViewBuilder
    func airQualityCard(_ dashboard: DashboardData) -> some View {
        let aqi = dashboard.air_quality.list.first?.main.aqi ?? 0
        let (label, color) = aqiLabelColor(aqi)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wind")
                    .foregroundColor(color)
                    .font(.title2)
                Text("Air Quality Index")
                    .font(.headline)
            }

            Text("🌿 \(label) (\(aqi))")
                .font(.title2)
                .bold()
                .foregroundColor(color)
        }
    }

    
    @ViewBuilder
    func conflictEventsSection(_ dashboard: DashboardData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🗞️ Recent Conflict Events")
                .font(.headline)

            if dashboard.conflict_events.isEmpty {
                Text("✅ No conflict alerts nearby.")
                    .foregroundColor(.green)
            } else {
                ForEach(dashboard.conflict_events.prefix(5)) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("⚠️ \(event.event_type)")
                            .font(.subheadline)
                            .bold()
                        Text(event.notes ?? "No description")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("🕒 \(event.event_date)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    }

