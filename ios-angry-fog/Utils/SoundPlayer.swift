//
//  SoundPlayer.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.3.2025.
//

import AVFoundation

struct SoundPlayer {
    static func playSound(named name: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
