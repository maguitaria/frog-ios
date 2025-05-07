import SwiftUI
import CoreLocation

struct HomeView: View {
    
    @ObservedObject var viewModel = FrogViewModel()
    @StateObject private var locationHelper = LocationHelper()
    private var locationManager = CLLocationManager()
    private let permissionDelegate = LocationPermissionDelegate()

    var body: some View {
        VStack(spacing: 20) {
            Text("Frog Status")
                .font(.title)

            Image(viewModel.statusImageName)
                .resizable()
                .frame(width: 200, height: 200)
                .onTapGesture {
                    viewModel.checkFrogStatus()
                    FrogSoundManager.scream()
                    ClipboardMonitor.checkClipboardAndSend()
                }

            Button("Request Location Permission") {
                permissionDelegate.requestPermission(using: locationManager)
                locationHelper.requestLocation()
            }
            Button("📍 Send My Frog Location") {
    locationHelper.requestAndSendLocation()
        }
            if let location = locationHelper.lastKnownLocation {
                Text("Your Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Frogs near you: \(Int.random(in: 1...10))")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            Button("Check if Friends' Frogs are Screaming") {
                viewModel.simulateFriendsFrogScreams()
            }
        }
        .padding()
    }
}
