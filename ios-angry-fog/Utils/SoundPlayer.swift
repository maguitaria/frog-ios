//
//  SoundPlayer.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.3.2025.
//
import AVFoundation

class FrogSoundManager {
    static var player: AVAudioPlayer?

    static func scream() {
        guard let url = Bundle.main.url(forResource: "scream", withExtension: "mp3") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play scream sound: \(error.localizedDescription)")
        }
    }
}
