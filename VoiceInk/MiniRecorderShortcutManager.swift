import Foundation
import KeyboardShortcuts
import AppKit

extension KeyboardShortcuts.Name {
    static let escapeRecorder = Self("escapeRecorder")
    static let cancelRecorder = Self("cancelRecorder")
    static let toggleEnhancement = Self("toggleEnhancement")
    // Power Mode selection shortcuts
    static let selectPowerMode1 = Self("selectPowerMode1")
    static let selectPowerMode2 = Self("selectPowerMode2")
    static let selectPowerMode3 = Self("selectPowerMode3")
    static let selectPowerMode4 = Self("selectPowerMode4")
    static let selectPowerMode5 = Self("selectPowerMode5")
    static let selectPowerMode6 = Self("selectPowerMode6")
    static let selectPowerMode7 = Self("selectPowerMode7")
    static let selectPowerMode8 = Self("selectPowerMode8")
    static let selectPowerMode9 = Self("selectPowerMode9")
}

@MainActor
class MiniRecorderShortcutManager: ObservableObject {
    private var whisperState: WhisperState
    private var visibilityTask: Task<Void, Never>?
    
    private var isCancelHandlerSetup = false
    
    // Double-tap Escape handling
    private var escFirstPressTime: Date? = nil
    private let escSecondPressThreshold: TimeInterval = 1.5
    private var isEscapeHandlerSetup = false
    private var escapeTimeoutTask: Task<Void, Never>?
    
    init(whisperState: WhisperState) {
        self.whisperState = whisperState
        setupVisibilityObserver()
        setupEnhancementShortcut()
        setupEscapeHandlerOnce()
        setupCancelHandlerOnce()
    }
    
    private func setupVisibilityObserver() {
        visibilityTask = Task { @MainActor in
            for await isVisible in whisperState.$isMiniRecorderVisible.values {
                if isVisible {
                    activateEscapeShortcut()
                    activateCancelShortcut()
                    KeyboardShortcuts.setShortcut(.init(.e, modifiers: .command), for: .toggleEnhancement)
                    setupPowerModeShortcuts()
                } else {
                    deactivateEscapeShortcut()
                    deactivateCancelShortcut()
                    removeEnhancementShortcut()
                    removePowerModeShortcuts()
                }
            }
        }
    }
    
    // Setup escape handler once
    private func setupEscapeHandlerOnce() {
        guard !isEscapeHandlerSetup else { return }
        isEscapeHandlerSetup = true
        
        KeyboardShortcuts.onKeyDown(for: .escapeRecorder) { [weak self] in
            Task { @MainActor in
                guard let self = self,
                      await self.whisperState.isMiniRecorderVisible else { return }
                
                // Don't process if custom shortcut is configured
                guard KeyboardShortcuts.getShortcut(for: .cancelRecorder) == nil else { return }
                
                let now = Date()
                if let firstTime = self.escFirstPressTime,
                   now.timeIntervalSince(firstTime) <= self.escSecondPressThreshold {
                    self.escFirstPressTime = nil
                    SoundManager.shared.playEscSound()
                    await self.whisperState.dismissMiniRecorder()
                } else {
                    self.escFirstPressTime = now
                    SoundManager.shared.playEscSound()
                    NotificationManager.shared.showNotification(
                        title: "Press ESC again to cancel recording",
                        type: .info,
                        duration: self.escSecondPressThreshold
                    )
                    self.escapeTimeoutTask = Task { [weak self] in
                        try? await Task.sleep(nanoseconds: UInt64((self?.escSecondPressThreshold ?? 1.5) * 1_000_000_000))
                        await MainActor.run {
                            self?.escFirstPressTime = nil
                        }
                    }
                }
            }
        }
    }
    
    private func activateEscapeShortcut() {
        // Don't activate if custom shortcut is configured
        guard KeyboardShortcuts.getShortcut(for: .cancelRecorder) == nil else { return }
        KeyboardShortcuts.setShortcut(.init(.escape), for: .escapeRecorder)
    }
    
    // Setup cancel handler once
    private func setupCancelHandlerOnce() {
        guard !isCancelHandlerSetup else { return }
        isCancelHandlerSetup = true
        
        KeyboardShortcuts.onKeyDown(for: .cancelRecorder) { [weak self] in
            Task { @MainActor in
                guard let self = self,
                      await self.whisperState.isMiniRecorderVisible,
                      KeyboardShortcuts.getShortcut(for: .cancelRecorder) != nil else { return }
                
                SoundManager.shared.playEscSound()
                await self.whisperState.dismissMiniRecorder()
            }
        }
    }
    
    private func activateCancelShortcut() {
        // Handler checks if shortcut exists
    }
    
    private func deactivateEscapeShortcut() {
        KeyboardShortcuts.setShortcut(nil, for: .escapeRecorder)
        escFirstPressTime = nil
        escapeTimeoutTask?.cancel()
        escapeTimeoutTask = nil
    }
    
    private func deactivateCancelShortcut() {
        // Shortcut managed by user settings
    }
    
    private func setupEnhancementShortcut() {
        KeyboardShortcuts.onKeyDown(for: .toggleEnhancement) { [weak self] in
            Task { @MainActor in
                guard let self = self,
                      await self.whisperState.isMiniRecorderVisible,
                      let enhancementService = await self.whisperState.getEnhancementService() else { return }
                enhancementService.isEnhancementEnabled.toggle()
            }
        }
    }
    
    private func setupPowerModeShortcuts() {
        KeyboardShortcuts.setShortcut(.init(.one, modifiers: .command), for: .selectPowerMode1)
        KeyboardShortcuts.setShortcut(.init(.two, modifiers: .command), for: .selectPowerMode2)
        KeyboardShortcuts.setShortcut(.init(.three, modifiers: .command), for: .selectPowerMode3)
        KeyboardShortcuts.setShortcut(.init(.four, modifiers: .command), for: .selectPowerMode4)
        KeyboardShortcuts.setShortcut(.init(.five, modifiers: .command), for: .selectPowerMode5)
        KeyboardShortcuts.setShortcut(.init(.six, modifiers: .command), for: .selectPowerMode6)
        KeyboardShortcuts.setShortcut(.init(.seven, modifiers: .command), for: .selectPowerMode7)
        KeyboardShortcuts.setShortcut(.init(.eight, modifiers: .command), for: .selectPowerMode8)
        KeyboardShortcuts.setShortcut(.init(.nine, modifiers: .command), for: .selectPowerMode9)
        
        // Setup handlers
        setupPowerModeHandler(for: .selectPowerMode1, index: 0)
        setupPowerModeHandler(for: .selectPowerMode2, index: 1)
        setupPowerModeHandler(for: .selectPowerMode3, index: 2)
        setupPowerModeHandler(for: .selectPowerMode4, index: 3)
        setupPowerModeHandler(for: .selectPowerMode5, index: 4)
        setupPowerModeHandler(for: .selectPowerMode6, index: 5)
        setupPowerModeHandler(for: .selectPowerMode7, index: 6)
        setupPowerModeHandler(for: .selectPowerMode8, index: 7)
        setupPowerModeHandler(for: .selectPowerMode9, index: 8)
    }
    
    private func setupPowerModeHandler(for shortcutName: KeyboardShortcuts.Name, index: Int) {
        KeyboardShortcuts.onKeyDown(for: shortcutName) { [weak self] in
            Task { @MainActor in
                guard let self = self,
                      await self.whisperState.isMiniRecorderVisible else { return }
                
                let powerModeManager = PowerModeManager.shared
                
                if powerModeManager.isPowerModeEnabled {
                    let availableConfigurations = powerModeManager.getAllAvailableConfigurations()
                    if index < availableConfigurations.count {
                        let selectedConfig = availableConfigurations[index]
                        powerModeManager.setActiveConfiguration(selectedConfig)
                        await ActiveWindowService.shared.applyConfiguration(selectedConfig)
                    }
                } else {
                    guard let enhancementService = await self.whisperState.getEnhancementService() else { return }
                    
                    let availablePrompts = enhancementService.allPrompts
                    if index < availablePrompts.count {
                        if !enhancementService.isEnhancementEnabled {
                            enhancementService.isEnhancementEnabled = true
                        }
                        
                        enhancementService.setActivePrompt(availablePrompts[index])
                    }
                }
            }
        }
    }
    
    private func removePowerModeShortcuts() {
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode1)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode2)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode3)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode4)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode5)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode6)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode7)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode8)
        KeyboardShortcuts.setShortcut(nil, for: .selectPowerMode9)
    }
    
    private func removeEnhancementShortcut() {
        KeyboardShortcuts.setShortcut(nil, for: .toggleEnhancement)
    }
    
    deinit {
        visibilityTask?.cancel()
        Task { @MainActor in
            deactivateEscapeShortcut()
            deactivateCancelShortcut()
            removeEnhancementShortcut()
            removePowerModeShortcuts()
        }
    }
} 