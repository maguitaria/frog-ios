import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var locationHelper = LocationHelper()
    @State private var statusMessage: String = "Welcome to FrogGuard 🐸"
    @State private var showSimulatedData = false
    @State private var simulatedData: [String: String] = [:]

    var body: some View {
        VStack(spacing: 16) {
            Text("🐸 FrogScan")
                .font(.largeTitle)
                .padding(.top)

            if let location = locationHelper.lastKnownLocation {
                Text("📍 Lat: \(String(format: "%.4f", location.coordinate.latitude)), Lon: \(String(format: "%.4f", location.coordinate.longitude))")
            } else {
                Text("📍 Getting your location...")
                    .foregroundColor(.gray)
            }

            if let town = locationHelper.lastKnownTown {
                Text("🏘 You're in \(town)")
                    .foregroundColor(.secondary)
            }

            Text("Status: \(statusMessage)")
                .foregroundColor(.blue)

            Button("Run FrogScan") {
                statusMessage = "Scanning... (Fake threat level: 🟢 Low)"
                locationHelper.requestAndSendLocation()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button("Show Simulated Privacy Leak") {
                simulatePrivacyDataAccess()
                showSimulatedData.toggle()
            }
            .buttonStyle(.bordered)
            .tint(.orange)

            if showSimulatedData {
                          VStack(alignment: .leading) {
                              Text("🔍 Simulated Data Access:")
                                  .font(.headline)
                              ForEach(Array(simulatedData.keys.sorted()), id: \.self) { key in
                                  if let value = simulatedData[key] {
                                      Text("• \(key): \(value)")
                                  }
                              }
                          }
                          .padding()
                          .background(Color.yellow.opacity(0.15))
                          .cornerRadius(10)
                      }

            Spacer()

            Text("FrogGuard keeps your data local unless explicitly shared.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .padding()
        .onAppear {
            locationHelper.requestPermission()
        }
    }

private func simulatePrivacyDataAccess() {
      simulatedData = [
          "Device": UIDevice.current.model,
          "OS": UIDevice.current.systemVersion,
          "Clipboard": UIPasteboard.general.string ?? "Nothing",
          "Battery Level": "\(Int(UIDevice.current.batteryLevel * 100))%"
      ]
      statusMessage = "Simulated privacy access complete."
  }
}

