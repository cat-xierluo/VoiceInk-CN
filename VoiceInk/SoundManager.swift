import Foundation
import AVFoundation
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    
    private var startSound: AVAudioPlayer?
    private var stopSound: AVAudioPlayer?
    private var escSound: AVAudioPlayer?
    
    @AppStorage("isSoundFeedbackEnabled") private var isSoundFeedbackEnabled = true
    
    private init() {
        Task(priority: .background) {
            await setupSounds()
        }
    }
    
    private func setupSounds() async {
        // Try loading directly from the main bundle
        if let startSoundURL = Bundle.main.url(forResource: "recstart", withExtension: "mp3"),
           let stopSoundURL = Bundle.main.url(forResource: "recstop", withExtension: "mp3"),
           let escSoundURL = Bundle.main.url(forResource: "esc", withExtension: "wav") {
            try? await loadSounds(start: startSoundURL, stop: stopSoundURL, esc: escSoundURL)
            return
        }
    }
    
    private func loadSounds(start startURL: URL, stop stopURL: URL, esc escURL: URL) async throws {
        do {
            startSound = try AVAudioPlayer(contentsOf: startURL)
            stopSound = try AVAudioPlayer(contentsOf: stopURL)
            escSound = try AVAudioPlayer(contentsOf: escURL)
            
            // Prepare sounds for instant playback first
            await MainActor.run {
                startSound?.prepareToPlay()
                stopSound?.prepareToPlay()
                escSound?.prepareToPlay()
            }
            
            // Set lower volume for all sounds after preparation
            startSound?.volume = 0.4
            stopSound?.volume = 0.4
            escSound?.volume = 0.3
        } catch {
            throw error
        }
    }
    
    func playStartSound() {
        guard isSoundFeedbackEnabled else { return }
        startSound?.volume = 0.4
        startSound?.play()
    }
    
    func playStopSound() {
        guard isSoundFeedbackEnabled else { return }
        stopSound?.volume = 0.4
        stopSound?.play()
    }
    
    func playEscSound() {
        guard isSoundFeedbackEnabled else { return }
        escSound?.volume = 0.3
        escSound?.play()
    }
    
    var isEnabled: Bool {
        get { isSoundFeedbackEnabled }
        set { isSoundFeedbackEnabled = newValue }
    }
} 
