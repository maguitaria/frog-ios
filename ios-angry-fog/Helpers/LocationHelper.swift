
import CoreLocation
import Foundation
import Combine

class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAndSendLocation() {
        print("📍 Requesting location...")
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("⚠️ No location found")
            return
        }

        self.lastKnownLocation = location
        print("✅ Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": timestamp
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: locationData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Sending location to backend...")
            NetworkManager.sendData(data: jsonString)
            print("✅ Location sent successfully: \(jsonString)")
        } else {
            print("❌ Failed to convert location to JSON")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get location: \(error.localizedDescription)")
    }
}
