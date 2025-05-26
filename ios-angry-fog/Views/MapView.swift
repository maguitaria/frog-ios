import SwiftUI
import CoreLocation
import CoreBluetooth
import CoreMotion
import UIKit
import MapKit
import Combine



struct LocationPoint: Identifiable, Codable {
   let latitude: Double
    let longitude: Double
    let timestamp: String
    let user: String?
}
struct FrogMapView: View {
    @State private var events: [ConflictEvent] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 60)
    )
    @State private var selectedEvent: ConflictEvent?
    @State private var filteredEvents: [ConflictEvent] = []
    @State private var showGrid = false
    @State private var countrySearch: String = ""
    @State private var offset = 0
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    TextField("Search country", text: $countrySearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: countrySearch) { _ in fetchConflictEvents() }
                    Button(action: {
                        showGrid.toggle()
                    }) {
                        Text(showGrid ? "Show Map" : "View as Grid")
                    }
                    .padding(.trailing)
                }

                if showGrid {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredEvents) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("📍 \(event.location)").bold()
                                    Text("🗺️ \(event.country) — \(event.region)").font(.subheadline)
                                    Text("🔹 Type: \(event.sub_event_type)").font(.subheadline)
                                    Text("👥 Actors: \(event.actor1) \(event.actor2)").font(.caption)
                                    Text("📝 \(event.notes)").font(.caption).lineLimit(6)
                                    Text("📅 \(event.event_date)").font(.caption2).foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .onAppear {
                                    if event.id == filteredEvents.last?.id {
                                        offset += 50
                                        fetchConflictEvents()
                                    }
                                }
                            }
                        }.padding()
                    }
                } else {
                    ZStack {
                        Map(coordinateRegion: $region, annotationItems: filteredEvents) { event in
                            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)) {
                                Button(action: {
                                    selectedEvent = event
                                }) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                }
                            }
                        }
                        .ignoresSafeArea()
                        .onReceive(Just(region.center)) { _ in
                            fetchConflictEvents()
                        }
                        if let selected = selectedEvent {
                            VStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(selected.event_type).font(.headline)
                                        Spacer()
                                        Button("Close") { selectedEvent = nil }.font(.caption)
                                    }
                                    Text(selected.location).font(.subheadline)
                                    Text(selected.notes).font(.caption).lineLimit(6)
                                    Text("📅 \(selected.event_date)").font(.caption2).foregroundColor(.gray)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Global Events Map")
        }
        .onAppear {
            fetchConflictEvents()
        }
    }

    func fetchConflictEvents() {
        guard !isLoading else { return }
        isLoading = true

        let apiKey = "6lkzj93Ra3lvdeBKiW7U"
        let email = "t2glma00@students.oamk.fi"
        let bbox = region.boundingBoxQuery()
        let query = "&country=\(countrySearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let urlString = "https://api.acleddata.com/acled/read?key=\(apiKey)&email=\(email)&limit=50"

        guard let url = URL(string: urlString) else { isLoading = false; return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { isLoading = false }
            guard let data = data else {
                print("❌ No data received")
                return
            }

            struct RawEvent: Decodable {
                let event_id_cnty: String, event_date: String, year: String, disorder_type: String
                let event_type: String, sub_event_type: String, actor1: String, assoc_actor_1: String
                let inter1: String, actor2: String, assoc_actor_2: String, inter2: String, interaction: String
                let civilian_targeting: String, iso: String, region: String, country: String
                let admin1: String, admin2: String, admin3: String, location: String
                let latitude: String, longitude: String, geo_precision: String
                let source: String, source_scale: String, notes: String, fatalities: String, tags: String, timestamp: String
            }

            struct EventResponse: Decodable {
                let data: [RawEvent]
            }

            do {
                let decoded = try JSONDecoder().decode(EventResponse.self, from: data)
                              let parsed: [ConflictEvent] = decoded.data.compactMap { item in
                                  guard let lat = Double(item.latitude), let lon = Double(item.longitude) else { return nil }
                                 
                    return ConflictEvent(
                        event_id_cnty: item.event_id_cnty, event_date: item.event_date, year: item.year,
                        disorder_type: item.disorder_type, event_type: item.event_type, sub_event_type: item.sub_event_type,
                        actor1: item.actor1, assoc_actor_1: item.assoc_actor_1, inter1: item.inter1, actor2: item.actor2,
                        assoc_actor_2: item.assoc_actor_2, inter2: item.inter2, interaction: item.interaction,
                        civilian_targeting: item.civilian_targeting, iso: item.iso, region: item.region, country: item.country,
                        admin1: item.admin1, admin2: item.admin2, admin3: item.admin3, location: item.location,
                        latitude: lat, longitude: lon, geo_precision: item.geo_precision,
                        source: item.source, source_scale: item.source_scale, notes: item.notes,
                        fatalities: item.fatalities, tags: item.tags, timestamp: item.timestamp
                    )
                }
                DispatchQueue.main.async {
                                   let sorted = parsed.sorted(by: { $0.event_date > $1.event_date })
                                   if offset == 0 {
                                       events = parsed
                                   } else {
                                       events.append(contentsOf: parsed)
                                   }
                                   filteredEvents = events.sorted(by: { $0.event_date > $1.event_date }).filter {
                                       region.contains(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude))
                                   }
                               }
            } catch {
                print("❌ Failed to decode: \(error)")
            }
        }.resume()
    }
}

extension MKCoordinateRegion {
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let minLat = center.latitude - span.latitudeDelta / 2
        let maxLat = center.latitude + span.latitudeDelta / 2
        let minLon = center.longitude - span.longitudeDelta / 2
        let maxLon = center.longitude + span.longitudeDelta / 2
        return (coordinate.latitude >= minLat && coordinate.latitude <= maxLat &&
                coordinate.longitude >= minLon && coordinate.longitude <= maxLon)
    }

    func boundingBoxQuery() -> String {
        let minLat = center.latitude - span.latitudeDelta / 2
        let maxLat = center.latitude + span.latitudeDelta / 2
        let minLon = center.longitude - span.longitudeDelta / 2
        let maxLon = center.longitude + span.longitudeDelta / 2
        return "latitude=\(minLat)|\(maxLat)&longitude=\(minLon)|\(maxLon)"
    }
}
