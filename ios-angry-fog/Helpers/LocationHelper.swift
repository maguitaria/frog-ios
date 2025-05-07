// 📄 LocationHelper.swift
import CoreLocation

class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.lastKnownLocation = location

    let timestamp = ISO8601DateFormatter().string(from: Date())
    let locationData = [
        "latitude": location.coordinate.latitude,
        "longitude": location.coordinate.longitude,
        "timestamp": timestamp
    ]

    if let jsonData = try? JSONSerialization.data(withJSONObject: locationData),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        NetworkManager.sendData(data: jsonString)
    }
}


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
