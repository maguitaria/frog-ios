
import Foundation
import CoreLocation
import Combine
final class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastKnownLocation: CLLocation?
    @Published var lastKnownTown: String?
    @Published var locationPermissionGranted: Bool = false
    var onLocationFetched: ((CLLocation) -> Void)?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        if locationPermissionGranted {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastKnownLocation = location
            self.reverseGeocode(location: location)
            self.sendLocationToBackend(location)
            self.onLocationFetched?(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }

    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, let town = placemark.locality else {
                print("⚠️ No town found.")
                return
            }
            DispatchQueue.main.async {
                self.lastKnownTown = town
            }
            print("🏘 Detected town: \(town)")
        }
    }

    private func sendLocationToBackend(_ location: CLLocation) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let payload: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": timestamp
        ]

        guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/location") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to encode payload: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to send location: \(error)")
            } else {
                print("📤 Location sent to backend successfully.")
            }
        }.resume()
    }
}
