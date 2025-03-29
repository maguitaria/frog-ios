//
//  LocationPermissionDelegate.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 29.3.2025.
//

import CoreLocation



class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate {
   func requestPermission(using manager: CLLocationManager) {
       manager.delegate = self
       manager.requestWhenInUseAuthorization()
   }

   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       switch status {
       case .authorizedAlways, .authorizedWhenInUse:
           print("✅ Location access granted")
       case .denied, .restricted:
           print("❌ Location access denied")
       case .notDetermined:
           print("🔄 Location access not determined")
       @unknown default:
           print("⚠️ Unknown location authorization status")
       }
   }
}
