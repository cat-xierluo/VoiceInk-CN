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
        setupSounds()
    }
    
    private func setupSounds() {
        print("Attempting to load sound files...")
        
        // Try loading directly from the main bundle
        if let startSoundURL = Bundle.main.url(forResource: "recstart", withExtension: "mp3"),
           let stopSoundURL = Bundle.main.url(forResource: "pastes", withExtension: "mp3"),
           let escSoundURL = Bundle.main.url(forResource: "esc", withExtension: "wav") {
            print("Found sounds in main bundle")
            try? loadSounds(start: startSoundURL, stop: stopSoundURL, esc: escSoundURL)
            return
        }
        
        print("⚠️ Could not find sound files in the main bundle")
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // List contents of the bundle for debugging
        if let bundleURL = Bundle.main.resourceURL {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
                print("Contents of bundle resource directory:")
                contents.forEach { print($0.lastPathComponent) }
            } catch {
                print("Error listing bundle contents: \(error)")
            }
        }
    }
    
    private func loadSounds(start startURL: URL, stop stopURL: URL, esc escURL: URL) throws {
        do {
            startSound = try AVAudioPlayer(contentsOf: startURL)
            stopSound = try AVAudioPlayer(contentsOf: stopURL)
            escSound = try AVAudioPlayer(contentsOf: escURL)
            
            // Set lower volume for all sounds
            startSound?.volume = 0.7
            stopSound?.volume = 0.7
            escSound?.volume = 0.3
            
            // Prepare sounds for instant playback
            startSound?.prepareToPlay()
            stopSound?.prepareToPlay()
            escSound?.prepareToPlay()
            
            print("✅ Successfully loaded all sound files")
        } catch {
            print("❌ Error loading sounds: \(error.localizedDescription)")
            throw error
        }
    }
    
    func playStartSound() {
        guard isSoundFeedbackEnabled else { return }
        startSound?.play()
    }
    
    func playStopSound() {
        guard isSoundFeedbackEnabled else { return }
        stopSound?.play()
    }
    
    func playEscSound() {
        guard isSoundFeedbackEnabled else { return }
        escSound?.play()
    }
    
    var isEnabled: Bool {
        get { isSoundFeedbackEnabled }
        set { isSoundFeedbackEnabled = newValue }
    }
} 
