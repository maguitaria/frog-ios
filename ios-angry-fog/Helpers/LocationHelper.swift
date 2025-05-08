import Foundation
import CoreLocation
import Combine
import UIKit

class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastKnownLocation: CLLocation?
    @Published var lastKnownTown: String?
    @Published var locationPermissionGranted: Bool = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAndSendLocation() {
        print("📡 Requesting one-time location update...")
        manager.requestLocation()
    }

    func requestPermission() {
        print("🔓 Requesting location permission...")
        manager.requestWhenInUseAuthorization()
    }

    func checkPermissionStatus() {
        let status = manager.authorizationStatus
        locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("⚠️ No location available.")
            return
        }

        DispatchQueue.main.async {
            self.lastKnownLocation = location
        }

        print("✅ Location received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        sendLocationToBackend(location)
        reverseGeocode(location: location)
        let timestamp = ISO8601DateFormatter().string(from: Date())
        UserDefaults.standard.set(timestamp, forKey: "lastScreamTime")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get location: \(error.localizedDescription)")
    }

    private func sendLocationToBackend(_ location: CLLocation) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let payload: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": timestamp
        ]

        print("📦 Sending payload to server: \(payload)")
        NetworkManager.sendData(dict: payload)
    }

    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("❌ Reverse geocoding error: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first,
                  let town = placemark.locality else {
                print("⚠️ No town found.")
                return
            }

            DispatchQueue.main.async {
                self.lastKnownTown = town
            }

            print("🏘 Detected town: \(town)")
        }
    }
}
