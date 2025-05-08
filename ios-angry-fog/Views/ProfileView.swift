//
//  ProfileView.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 29.3.2025.
//

import SwiftUICore
import SwiftUI
import UIKit

struct ProfileView: View {
    let frogID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    let lastScream = UserDefaults.standard.string(forKey: "lastScreamTime") ?? "Never"

    var body: some View {
        VStack(spacing: 25) {
            Text("🐸 My Frog Profile")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 10) {
                Text("🆔 Frog ID")
                    .font(.headline)
                Text(frogID)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 10) {
                Text("📣 Last Scream")
                    .font(.headline)
                Text(lastScream)
                    .font(.title3)
                    .foregroundColor(.green)
            }

            VStack(spacing: 10) {
                Text("🎖️ Rank")
                    .font(.headline)
                Text("Screaming Tadpole")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}




struct SettingsView: View {
    @AppStorage("secureMode") var secureMode = false
    @AppStorage("locationEnabled") var locationEnabled = true
    @AppStorage("clipboardEnabled") var clipboardEnabled = true
    @AppStorage("testMode") var testMode = false

    let backendURL = "https://frog-ios-xm5a.onrender.com/"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🛡 Privacy Settings")) {
                    Toggle("Secure Mode (Fake)", isOn: $secureMode)
                    Toggle("Enable Location Tracking", isOn: $locationEnabled)
                    Toggle("Enable Clipboard Access", isOn: $clipboardEnabled)
                }

                Section(header: Text("🧪 Developer Options")) {
                    Toggle("Enable Test Mode", isOn: $testMode)
                    Button("Reset App Data") {
                        resetAppData()
                    }
                }

                Section(header: Text("📱 App Information")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Backend URL")
                        Spacer()
                        Text(backendURL)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Frog Species")
                        Spacer()
                        Text("🟢 Angry Screamer")
                            .foregroundColor(.green)
                    }
                }

                Section(header: Text("About")) {
                                Text("FrogGuard is a civil safety companion with privacy-focused design.")
                            }
            }
            .navigationTitle("Settings")
        }
    }

    func resetAppData() {
        secureMode = false
        locationEnabled = true
        clipboardEnabled = true
        testMode = false
        print("🧼 App data reset.")
    }
}
