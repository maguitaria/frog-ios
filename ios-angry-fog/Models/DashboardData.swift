import Foundation

struct DashboardData: Decodable {
    struct AirQuality: Decodable {
        struct AQIWrapper: Decodable {
            struct Main: Decodable {
                let aqi: Int
            }
            let main: Main
        }
        let list: [AQIWrapper]
    }

    struct ConflictEvent: Decodable, Identifiable {
        let id = UUID()
        let event_type: String
        let event_date: String
        let location: String
        let notes: String?
    }

    let air_quality: AirQuality
    let conflict_events: [ConflictEvent]
}
