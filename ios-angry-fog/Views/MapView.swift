import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.2, longitude: 16.3),
        span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
    )
    @State private var showList = false
    @State private var events: [DashboardData.ConflictEvent] = []

    var body: some View {
        VStack(spacing: 0) {
            Picker("View Mode", selection: $showList) {
                Text("🗺️ Map").tag(false)
                Text("📋 List").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if showList {
                ConflictListView(events: events)
            } else {
                ZStack(alignment: .bottom) {
                    Map(coordinateRegion: $region, annotationItems: events) { event in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: 48.2, longitude: 16.3)) {
                            VStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(event.event_type)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(6)
                            }
                        }
                    }

                    if !events.isEmpty {
                        EventFlashcardView(events: events)
                            .padding(.bottom, 10)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear(perform: fetchEvents)
    }

    func fetchEvents() {
        guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/dashboard?lat=48.2&lon=16.3") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(DashboardData.self, from: data) else { return }

            DispatchQueue.main.async {
                events = decoded.conflict_events
            }
        }.resume()
    }
}

struct ConflictListView: View {
    var events: [DashboardData.ConflictEvent]

    var body: some View {
        List(events) { event in
            VStack(alignment: .leading, spacing: 4) {
                Text("⚠️ \(event.event_type)")
                    .font(.headline)
                Text(event.notes ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("📅 \(event.event_date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

struct EventFlashcardView: View {
    var events: [DashboardData.ConflictEvent]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(events.prefix(5)) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("⚠️ \(event.event_type)")
                            .font(.headline)
                        Text(event.notes ?? "No description")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("📅 \(event.event_date)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(width: 250)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.thinMaterial)
    }
}
