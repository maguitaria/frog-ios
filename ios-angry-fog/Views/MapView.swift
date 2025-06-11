import SwiftUI
import CoreLocation
import MapKit
struct FrogMapView: View {
    @ObservedObject var api = APIService()
    @ObservedObject var locationHelper: LocationHelper
        @State private var showLeakPanel = false
    let userLocation: CLLocationCoordinate2D
    @State private var nearestEvents: [ConflictEvent] = []
    var body: some View {
        
        Map(coordinateRegion: .constant(
            MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))),
            annotationItems: api.nearestEvents
        ) {
            
            event in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
        }
        .ignoresSafeArea()
        
        .navigationTitle("Global Events Map")
        .onAppear {
            Task {
                await api.fetchNearbyEvents(at: userLocation, country: locationHelper.country ?? "")
                nearestEvents = api.nearestEvents
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
