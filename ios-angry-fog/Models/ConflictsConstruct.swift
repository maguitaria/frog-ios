import Foundation
import CoreLocation

struct ConflictEvent: Identifiable {
    let id = UUID()
    let event_id_cnty: String
    let event_date: String
    let event_type: String
    let sub_event_type: String
    let country: String
    let location: String
    let notes: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let timestamp: String
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
