import SwiftUI
import CoreLocation
import MapKit
struct FrogMapView: View {
    @ObservedObject var api = APIService()
    let userLocation: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(
            MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))),
            annotationItems: api.nearestEvents
        ) { event in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
        }
        .onAppear {
            Task {
                await api.fetchNearbyEvents(at: userLocation)
            }
        }
    }
}
