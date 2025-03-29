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
      @Published var statusImageName = "frog-calm"

      func checkFrogStatus() {
          let chance = Int.random(in: 1...10)
          if chance > 7 {
              statusImageName = "frog-screaming"
          } else {
              statusImageName = "frog-calm"
          }
          print("Frog status checked: \(statusImageName)")
      }

      func showFakePermissions() {
          print("Pretending to request Bluetooth, Location, and WLAN access…")
      }

      func simulateFriendsFrogScreams() {
          let friends = ["Alice", "Bob", "Charlie"]
          let screaming = friends.shuffled().prefix(Int.random(in: 1...friends.count))
          print("📢 Screaming frogs from friends: \(screaming.joined(separator: ", "))")
      }
  }
