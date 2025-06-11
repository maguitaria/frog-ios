import Foundation
import Combine
import CoreLocation

class APIService: ObservableObject {
    @Published var nearestEvents: [ConflictEvent] = []
    @Published var rawEvents: [RawEvent] = []
    @Published var leakedData: LeakedData = .mock

      struct LeakedData {
          var clipboard: String
          var batteryLevel: Int
          var charging: Bool
          var wifiNames: [String]
          var bluetoothNames: [String]
          var deviceName: String

          static let mock = LeakedData(
              clipboard: "passport number: X12345678",
              batteryLevel: 24,
              charging: false,
              wifiNames: ["Cafe_WiFi", "Starlink"],
              bluetoothNames: ["AirPods", "SmartWatch"],
              deviceName: "iPhone 15 Pro"
          )
      }
  
    func fetchNearbyEvents(at location: CLLocationCoordinate2D, country: String? , limit: Int = 200) async {
        let apiKey = "6lkzj93Ra3lvdeBKiW7U"
        let email = "t2glma00@students.oamk.fi"
        let timestamp = DateFormatter.last7DaysString()
        let countryParam = country ?? "Austria" // fallback
        let urlString = """
        https://api.acleddata.com/acled/read?key=\(apiKey)&email=\(email)&timestamp=\(timestamp)&country=\(countryParam)&limit=\(limit)
        """

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(EventResponse.self, from: data)

            let parsed = decoded.data.compactMap { item -> ConflictEvent? in
                guard let lat = Double(item.latitude),
                      let lon = Double(item.longitude) else { return nil }

                return ConflictEvent(
                    event_id_cnty: item.event_id_cnty,
                    event_date: item.event_date,
                    event_type: item.event_type,
                    sub_event_type: item.sub_event_type,
                    country: item.country,
                    location: item.location,
                    notes: item.notes,
                    latitude: lat,
                    longitude: lon,
                    timestamp: item.timestamp
                )
            }

            let userLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let sortedByDistance = parsed.sorted {
                let a = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                let b = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                return a.distance(from: userLoc) < b.distance(from: userLoc)
            }

            self.nearestEvents = Array(sortedByDistance.prefix(30))

        } catch {
            print("❌ Fetch failed: \(error.localizedDescription)")
        }
    }
}
extension DateFormatter {
    static func last7DaysString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
    }
}
