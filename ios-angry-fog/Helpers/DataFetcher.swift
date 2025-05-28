//
//  DataFetcher.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.5.2025.
//


import Foundation
import CoreLocation
import WeatherKit

@MainActor
class DataFetcher: ObservableObject {
    static let shared = DataFetcher()
    private let weatherService = WeatherService.shared

    func fetchProtests(near location: CLLocation) async -> [ConflictEvent] {
        let urlString = "https://api.acleddata.com/acled/read?key=6lkzj93Ra3lvdeBKiW7U&email=t2glma00@students.oamk.fi&limit=100"
        guard let url = URL(string: urlString) else { return [] }

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

            return parsed.sorted {
                CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                    .distance(from: location) <
                CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                    .distance(from: location)
            }
        } catch {
            print("❌ Protest fetch error: \(error)")
            return []
        }
    }

    func fetchWeather(for location: CLLocation) async -> Weather? {
        do {
            return try await weatherService.weather(for: location)
        } catch {
            print("❌ Weather fetch error: \(error)")
            return nil
        }
    }
}
