

import SwiftUI
import CoreLocation
import UserNotifications

struct HomeView: View {
    @StateObject private var locationHelper = LocationHelper()
    @State private var statusMessage: String = "Ready to scan"
    @State private var dashboardData: DashboardData?
    @State private var showSimulatedData = false
    @State private var simulatedData: [String: String] = [:]
    @State private var isLoadingDashboard = false

    let apiKey = Secrets.value(forKey: "ACLED_API_KEY")
    let email = Secrets.value(forKey: "ACLED_EMAIL")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("🐸 FrogGuard Safety Dashboard")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    if let town = locationHelper.lastKnownTown {
                        Text("📍 You are in \(town)")
                            .foregroundColor(.secondary)
                    }

                    if let location = locationHelper.lastKnownLocation {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Lat: \(String(format: "%.4f", location.coordinate.latitude))", systemImage: "location.fill")
                            Label("Lon: \(String(format: "%.4f", location.coordinate.longitude))", systemImage: "location.north.line")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    if isLoadingDashboard {
                        ProgressView("Loading safety info...")
                    } else if let dashboard = dashboardData {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🧭 Local Conditions")
                                .font(.headline)

                            if let aqi = dashboard.air_quality.list.first?.main.aqi {
                                Label("Air Quality Index: \(aqiLabel(aqi))", systemImage: "wind")
                                    .foregroundColor(aqiColor(aqi))
                            }

                            if dashboard.conflict_events.isEmpty {
                                Label("No conflict alerts nearby", systemImage: "checkmark.seal")
                                    .foregroundColor(.green)
                            } else {
                                Label("⚠️ \(dashboard.conflict_events.count) conflict events nearby", systemImage: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }

                    Button("Rescan Area") {
                        startDashboardScan()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button("Simulate Privacy Leak") {
                        simulatePrivacyDataAccess()
                        showSimulatedData.toggle()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    if showSimulatedData {
                        VStack(alignment: .leading) {
                            Text("🔍 Simulated Access")
                                .font(.headline)
                            ForEach(simulatedData.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack {
                                    Text(key + ":")
                                    Spacer()
                                    Text(value)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }

                    Spacer(minLength: 20)

                    Text("Your data stays private unless shared.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Home")
        }
        .onAppear {
       
            startDashboardScan()
            locationHelper.onLocationFetched = { location in
                print("🛰️ Triggering conflict scan")
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                let date = ISO8601DateFormatter().string(from: Date()).prefix(10)
                let apiKey = Secrets.value(forKey: "ACLED_API_KEY")
                let email = Secrets.value(forKey: "ACLED_EMAIL")
                let urlStr = "https://api.acleddata.com/acled/read?key=\\(apiKey)&email=\\(email)&limit=5&event_date=2024-01-01|\\(date)&latitude=\\(lat)&longitude=\\(lon)&radius=30"

                guard let url = URL(string: urlStr) else { return }

                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else { return }
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let events = json["data"] as? [[String: Any]], !events.isEmpty {
                        let first = events[0]
                        let eventType = first["event_type"] as? String ?? "Conflict"
                        let notes = first["notes"] as? String ?? "Check map for more."
                        DispatchQueue.main.async {
                            statusMessage = "⚠️ Conflict: \\(eventType)"
                           // sendLocalAlert(title: "Nearby Conflict", body: notes)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("✅ No conflict events found")
                        }
                    }
                }.resume()
            }
        }
    }

    private func startDashboardScan() {
        guard let location = locationHelper.lastKnownLocation else { return }
        isLoadingDashboard = true

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        let urlStr = "https://frog-ios-xm5a.onrender.com/dashboard?lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlStr) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            isLoadingDashboard = false
            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DashboardData.self, from: data)
                DispatchQueue.main.async {
                    self.dashboardData = decoded
                }
            } catch {
                print("❌ Decode error: \(error)")
            }
        }.resume()
    }

    private func simulatePrivacyDataAccess() {
        simulatedData = [
            "Device": UIDevice.current.model,
            "OS": UIDevice.current.systemVersion,
            "Clipboard": UIPasteboard.general.string ?? "Empty",
            "Battery Level": "\(Int(UIDevice.current.batteryLevel * 100))%"
        ]
        statusMessage = "Simulated access complete."
    }

    private func aqiLabel(_ index: Int) -> String {
        switch index {
        case 1: return "Good"
        case 2: return "Fair"
        case 3: return "Moderate"
        case 4: return "Poor"
        case 5: return "Very Poor"
        default: return "Unknown"
        }
    }

    private func aqiColor(_ index: Int) -> Color {
        switch index {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        case 5: return .purple
        default: return .gray
        }
    }
}
