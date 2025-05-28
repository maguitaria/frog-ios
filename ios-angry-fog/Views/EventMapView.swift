//
//  EventMapView.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 27.5.2025.
//


import SwiftUI
import MapKit

struct EventMapView: UIViewRepresentable {
    var events: [ConflictEvent]
    var userLocation: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.setRegion(MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)), animated: true)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.setRegion(MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)), animated: true)

        let annotations = events.map { event -> MKPointAnnotation in
            let ann = MKPointAnnotation()
            let lat = Double(event.latitude) ?? 0.0
            let lon = Double(event.longitude) ?? 0.0
            ann.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            ann.title = "\(event.sub_event_type) – \(event.country)"
            ann.subtitle = event.notes
            return ann
        }
        mapView.addAnnotations(annotations)
    }
}
