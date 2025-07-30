import AppKit
import Combine
import Foundation
import SwiftUI
import MediaRemoteAdapter

/// Pauses media when recording starts, resumes when recording stops
class PlaybackController: ObservableObject {
    static let shared = PlaybackController()
    private var mediaController: MediaRemoteAdapter.MediaController
    private var wasPlayingWhenRecordingStarted = false
    private var isMediaPlaying = false
    
    @Published var isPauseMediaEnabled: Bool = UserDefaults.standard.bool(forKey: "isPauseMediaEnabled") {
        didSet {
            UserDefaults.standard.set(isPauseMediaEnabled, forKey: "isPauseMediaEnabled")
        }
    }
    
    private init() {
        mediaController = MediaRemoteAdapter.MediaController()
        
        if !UserDefaults.standard.contains(key: "isPauseMediaEnabled") {
            UserDefaults.standard.set(true, forKey: "isPauseMediaEnabled")
        }
        
        mediaController.startListening()
        
        // Listen for track changes to know if media is playing
        mediaController.onTrackInfoReceived = { [weak self] trackInfo in
            self?.isMediaPlaying = trackInfo.payload.isPlaying ?? false
        }
        
        mediaController.onListenerTerminated = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.mediaController.startListening()
            }
        }
    }
    
    func pauseMedia() async {
        guard isPauseMediaEnabled else { return }

        if isMediaPlaying {
            wasPlayingWhenRecordingStarted = true
            mediaController.pause()
        } else {
            wasPlayingWhenRecordingStarted = false
        }
    }

    func resumeMedia() async {
        guard isPauseMediaEnabled, wasPlayingWhenRecordingStarted else { return }
        
        mediaController.play()
    }
}

extension UserDefaults {
    var isPauseMediaEnabled: Bool {
        get { bool(forKey: "isPauseMediaEnabled") }
        set { set(newValue, forKey: "isPauseMediaEnabled") }
    }
} 