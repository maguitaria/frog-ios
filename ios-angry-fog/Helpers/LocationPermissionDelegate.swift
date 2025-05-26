//
//  LocationPermissionDelegate 2.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.4.2025.
//



// 📄 LocationPermissionDelegate.swift
import CoreLocation

class LocationPermissionDelegate {
    func requestPermission(using manager: CLLocationManager) {
        manager.requestWhenInUseAuthorization()
    }
    func requestAndSendLocation(using manager: CLLocationManager) {
        manager.requestLocation()
    }
}
