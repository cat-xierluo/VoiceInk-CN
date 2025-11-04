import AppKit
import Combine
import Foundation
import SwiftUI
import MediaRemoteAdapter
class PlaybackController: ObservableObject {
    static let shared = PlaybackController()
    private var mediaController: MediaRemoteAdapter.MediaController
    private var wasPlayingWhenRecordingStarted = false
    private var isMediaPlaying = false
    private var lastKnownTrackInfo: TrackInfo?
    private var originalMediaAppBundleId: String?

    
    @Published var isPauseMediaEnabled: Bool = UserDefaults.standard.bool(forKey: "isPauseMediaEnabled") {
        didSet {
            UserDefaults.standard.set(isPauseMediaEnabled, forKey: "isPauseMediaEnabled")
            
            if isPauseMediaEnabled {
                startMediaTracking()
            } else {
                stopMediaTracking()
            }
        }
    }
    
    private init() {
        mediaController = MediaRemoteAdapter.MediaController()
        
        if !UserDefaults.standard.contains(key: "isPauseMediaEnabled") {
            UserDefaults.standard.set(false, forKey: "isPauseMediaEnabled")
        }
        
        setupMediaControllerCallbacks()
        
        if isPauseMediaEnabled {
            startMediaTracking()
        }
    }
    
    private func setupMediaControllerCallbacks() {
        mediaController.onTrackInfoReceived = { [weak self] trackInfo in
            self?.isMediaPlaying = trackInfo.payload.isPlaying ?? false
            self?.lastKnownTrackInfo = trackInfo
        }
        
        mediaController.onListenerTerminated = { }
    }
    
    private func startMediaTracking() {
        mediaController.startListening()
    }
    
    private func stopMediaTracking() {
        mediaController.stopListening()
        isMediaPlaying = false
        lastKnownTrackInfo = nil
        wasPlayingWhenRecordingStarted = false
        originalMediaAppBundleId = nil
    }
    
    func pauseMedia() async {
        wasPlayingWhenRecordingStarted = false
        originalMediaAppBundleId = nil
        
        guard isPauseMediaEnabled, 
              isMediaPlaying,
              lastKnownTrackInfo?.payload.isPlaying == true,
              let bundleId = lastKnownTrackInfo?.payload.bundleIdentifier else {
            return
        }
        
        wasPlayingWhenRecordingStarted = true
        originalMediaAppBundleId = bundleId
        
        // Add a small delay to ensure state is set before sending command
        try? await Task.sleep(nanoseconds: 50_000_000) 
        
        mediaController.pause()
    }

    func resumeMedia() async {
        let shouldResume = wasPlayingWhenRecordingStarted
        let originalBundleId = originalMediaAppBundleId
        
        defer {
            wasPlayingWhenRecordingStarted = false
            originalMediaAppBundleId = nil
        }
        
        guard isPauseMediaEnabled,
              shouldResume,
              let bundleId = originalBundleId else {
            return
        }
        
        guard isAppStillRunning(bundleId: bundleId) else {
            return
        }
        
        guard let currentTrackInfo = lastKnownTrackInfo,
              let currentBundleId = currentTrackInfo.payload.bundleIdentifier,
              currentBundleId == bundleId,
              currentTrackInfo.payload.isPlaying == false else {
            return
        }
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        mediaController.play()
    }
    
    private func isAppStillRunning(bundleId: String) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { $0.bundleIdentifier == bundleId }
    }
}

extension UserDefaults {
    var isPauseMediaEnabled: Bool {
        get { bool(forKey: "isPauseMediaEnabled") }
        set { set(newValue, forKey: "isPauseMediaEnabled") }
    }
} 

