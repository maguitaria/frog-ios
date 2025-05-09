import SwiftUI
import MapKit

struct ConflictEvent: Identifiable, Decodable {
    let id: String
    let event_type: String
    let location: String
    let notes: String
    let event_date: String
    let latitude: Double
    let longitude: Double
}

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 70, longitudeDelta: 140)
    )

    @State private var events: [ConflictEvent] = []
    @State private var selectedEvent: ConflictEvent?

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: events) { event in
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

                if let selected = selectedEvent {
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(selected.event_type)
                                    .font(.headline)
                                Spacer()
                                Button("Close") {
                                    selectedEvent = nil
                                }
                                .font(.caption)
                            }
                            Text(selected.location)
                                .font(.subheadline)
                            Text(selected.notes)
                                .font(.caption)
                                .lineLimit(3)
                            Text("📅 \(selected.event_date)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding()
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
        let apiKey = "6lkzj93Ra3lvdeBKiW7U"
        let email = "t2glma00@students.oamk.fi"
        let urlString = "https://api.acleddata.com/acled/read?key=\(apiKey)&email=\(email)&limit=50"

        guard let url = URL(string: "https://your-backend-or-proxy.com/events") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([ConflictEvent].self, from: data)
                DispatchQueue.main.async {
                    self.events = decoded
                }
            } catch {
                print("❌ Failed to decode: \(error)")
            }
        }.resume()
    }
}
