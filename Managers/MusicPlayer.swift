// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation
import AVFoundation
import Observation

@Observable
final class MusicPlayer {
    static let tracks: [(name: String, file: String)] = [
        ("Sakin Piyano", "sakin_piyano"),
        ("Yağmur Sesi",  "yagmur_sesi"),
        ("Derin Ambiyans", "derin_ambiyans"),
    ]

    private var player: AVAudioPlayer?
    var currentTrack: String? = nil
    var isPlaying: Bool { player?.isPlaying ?? false }

    func play(file: String, volume: Float) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = volume
        player?.play()
        currentTrack = file
    }

    func setVolume(_ v: Float) { player?.volume = v }

    func stop() {
        player?.stop()
        player = nil
        currentTrack = nil
    }
}
