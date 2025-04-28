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

        NetworkManager.sendData(data: "Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
