import SwiftUI
import MapKit
import CoreLocation

struct FrogMapView: View {
    @ObservedObject var api: APIService
    @ObservedObject var locationHelper: LocationHelper

    let userLocation: CLLocationCoordinate2D
    @State private var showLeakPanel = false
    @State private var filteredEvents: [ConflictEvent] = []
    @State private var selectedEvent: ConflictEvent?
    @State private var showGrid = false
    @State private var countrySearch = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header

                if showGrid {
                    eventGrid
                } else {
                    eventMap
                }
            }
            .navigationTitle("Global Events Map")
        }
        .onAppear {
            region.center = userLocation
            Task {
                await api.fetchNearbyEvents(at: userLocation, country: locationHelper.country ?? "")
                self.filteredEvents = api.rawEvents.compactMap { ConflictEvent(from: $0) }
            }
        }
    }

    var header: some View {
        HStack {
            TextField("Search country", text: $countrySearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: { showGrid.toggle() }) {
                Text(showGrid ? "Show Map" : "View as Grid")
            }
            .padding(.trailing)
        }
        .padding(.top)
    }

    var eventGrid: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🗺️ \(event.country) — \(event.location)").font(.subheadline)
                        Text("🔹 Type: \(event.sub_event_type)").font(.subheadline)
                      //  Text("👥 Actors: \(event.actor1) \(event.actor2)").font(.caption)
                        Text("📝 \(event.notes)").font(.caption).lineLimit(6)
                        Text("📅 \(event.event_date)").font(.caption2).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    var eventMap: some View {
        ZStack {
            Map(
                coordinateRegion: $region,
                annotationItems: filteredEvents
            ) { event in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: event.latitude,
                        longitude: event.longitude
                    )
                ) {
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
                            .lineLimit(6)
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
            if showLeakPanel {
                      VStack {
                          Spacer()
                          VStack(alignment: .leading, spacing: 8) {
                              Text("🔓 Leaked Device Info").font(.headline)
                              Divider()
                              Text("📋 Clipboard: \(api.leakedData.clipboard)")
                              Text("🔋 Battery: \(api.leakedData.batteryLevel)% \(api.leakedData.charging ? "(Charging)" : "")")
                              Text("📡 Wi-Fi: \(api.leakedData.wifiNames.joined(separator: ", "))")
                              Text("🔵 Bluetooth: \(api.leakedData.bluetoothNames.joined(separator: ", "))")
                              Text("📱 Device: \(api.leakedData.deviceName)")
                          }
                          .padding()
                          .background(Color.black.opacity(0.8))
                          .foregroundColor(.white)
                          .cornerRadius(12)
                          .padding()
                      }
                      .transition(.move(edge: .bottom))
                  }
              }
              .gesture(
                  LongPressGesture(minimumDuration: 2.0)
                      .onEnded { _ in withAnimation { showLeakPanel.toggle() } }
              )
    }
}
