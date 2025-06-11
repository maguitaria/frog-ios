import Foundation
import CoreLocation

struct ConflictEvent: Identifiable {
    var id = UUID()
    var event_id_cnty: String
    var event_date: String
    var event_type: String
    var sub_event_type: String
    var country: String
    var location: String
    var notes: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var timestamp: String
}

struct RawEvent: Codable {
    let event_id_cnty: String
    let event_date: String
    let event_type: String
    let sub_event_type: String
    let country: String
    let location: String
    let latitude: String
    let longitude: String
    let notes: String
    let timestamp: String
}

struct EventResponse: Codable {
    let data: [RawEvent]
}
extension ConflictEvent {
    init?(from raw: RawEvent) {
        guard
            let lat = CLLocationDegrees(raw.latitude),
            let lon = CLLocationDegrees(raw.longitude)
        else {
            return nil
        }

        self.id = UUID()
        self.event_id_cnty = raw.event_id_cnty
        self.event_date = raw.event_date
        self.event_type = raw.event_type
        self.sub_event_type = raw.sub_event_type
        self.country = raw.country
        self.location = raw.location
        self.notes = raw.notes
        self.latitude = lat
        self.longitude = lon
        self.timestamp = raw.timestamp
    }
}
