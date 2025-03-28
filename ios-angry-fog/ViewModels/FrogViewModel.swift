//
//  FrogViewModel.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.3.2025.
//

import Foundation
import AVFoundation

class FrogViewModel: ObservableObject {
    @Published var isScreaming = false

    func triggerScream() {
        isScreaming = true
        SoundPlayer.playSound(named: "scream")

        // Reset state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isScreaming = false
        }

        // Simulate broadcast to other devices
        print("Sending fake scream signal to nearby devices…")
    }

    func showFakePermissions() {
        print("Pretending to request Bluetooth, Location, and WLAN access…")
    }
}
