import Foundation
import AppKit
import os

class ActiveWindowService: ObservableObject {
    static let shared = ActiveWindowService()
    @Published var currentApplication: NSRunningApplication?
    private var enhancementService: AIEnhancementService?
    private let browserURLService = BrowserURLService.shared
    private var whisperState: WhisperState?
    
    private let logger = Logger(
<<<<<<< HEAD
        subsystem: "com.prakashjoshipax.VoiceInk",
=======
        subsystem: "com.prakashjoshipax.voiceink",
>>>>>>> upstream/main
        category: "browser.detection"
    )
    
    private init() {}
    
    func configure(with enhancementService: AIEnhancementService) {
        self.enhancementService = enhancementService
    }
    
    func configureWhisperState(_ whisperState: WhisperState) {
        self.whisperState = whisperState
    }
    
    func applyConfigurationForCurrentApp() async {
<<<<<<< HEAD
        guard PowerModeManager.shared.isPowerModeEnabled else {
            return
        }

        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let bundleIdentifier = frontmostApp.bundleIdentifier else { return }
        
        await MainActor.run {
            currentApplication = frontmostApp
        }
        
        if let browserType = BrowserType.allCases.first(where: { $0.bundleIdentifier == bundleIdentifier }) {
            logger.debug("🌐 Detected Browser: \(browserType.displayName)")
            
            do {
                logger.debug("📝 Attempting to get URL from \(browserType.displayName)")
                let currentURL = try await browserURLService.getCurrentURL(from: browserType)
                logger.debug("📍 Successfully got URL: \(currentURL)")
                
                if let config = PowerModeManager.shared.getConfigurationForURL(currentURL) {
                    logger.debug("⚙️ Found URL Configuration: \(config.name) for URL: \(currentURL)")
                    await MainActor.run {
                        PowerModeManager.shared.setActiveConfiguration(config)
                    }
                    await applyConfiguration(config)
                    return
                } else {
                    logger.debug("📝 No URL configuration found for: \(currentURL)")
=======
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let bundleIdentifier = frontmostApp.bundleIdentifier else {
            return
        }

        await MainActor.run {
            currentApplication = frontmostApp
        }

        var configToApply: PowerModeConfig?

        if let browserType = BrowserType.allCases.first(where: { $0.bundleIdentifier == bundleIdentifier }) {
            do {
                let currentURL = try await browserURLService.getCurrentURL(from: browserType)
                if let config = PowerModeManager.shared.getConfigurationForURL(currentURL) {
                    configToApply = config
>>>>>>> upstream/main
                }
            } catch {
                logger.error("❌ Failed to get URL from \(browserType.displayName): \(error.localizedDescription)")
            }
        }
<<<<<<< HEAD
        
        let config = PowerModeManager.shared.getConfigurationForApp(bundleIdentifier) ?? PowerModeManager.shared.defaultConfig
        
        await MainActor.run {
            PowerModeManager.shared.setActiveConfiguration(config)
        }
        
        await applyConfiguration(config)
    }
    
    /// Applies a specific configuration
    func applyConfiguration(_ config: PowerModeConfig) async {
        guard let enhancementService = enhancementService else { return }
        
        // Capture current state before making changes
        let wasScreenCaptureEnabled = await MainActor.run { 
            enhancementService.useScreenCaptureContext 
        }
        let wasEnhancementEnabled = await MainActor.run { 
            enhancementService.isEnhancementEnabled 
        }

        await MainActor.run {
            enhancementService.isEnhancementEnabled = config.isAIEnhancementEnabled
            enhancementService.useScreenCaptureContext = config.useScreenCapture
            
            if config.isAIEnhancementEnabled {
                if let promptId = config.selectedPrompt,
                   let uuid = UUID(uuidString: promptId) {
                    enhancementService.selectedPromptId = uuid
                } else {
                    if let firstPrompt = enhancementService.allPrompts.first {
                        enhancementService.selectedPromptId = firstPrompt.id
                    }
                }
            }
            
            if config.isAIEnhancementEnabled, 
               let aiService = enhancementService.getAIService() {
                
                if let providerName = config.selectedAIProvider,
                   let provider = AIProvider(rawValue: providerName) {
                    aiService.selectedProvider = provider
                    
                    if let model = config.selectedAIModel,
                       !model.isEmpty {
                        aiService.selectModel(model)
                    }
                }
            }
            
            if let language = config.selectedLanguage {
                UserDefaults.standard.set(language, forKey: "SelectedLanguage")
                NotificationCenter.default.post(name: .languageDidChange, object: nil)
            }
        }
        
        if let whisperState = self.whisperState,
           let modelName = config.selectedTranscriptionModelName,
           let selectedModel = await whisperState.allAvailableModels.first(where: { $0.name == modelName }) {
            
            let currentModelName = await MainActor.run { whisperState.currentTranscriptionModel?.name }
            
            // Only change the model if it's different from the current one.
            if currentModelName != modelName {
                // Set the new model as default. This works for both local and cloud models.
                await whisperState.setDefaultTranscriptionModel(selectedModel)
                
                // The cleanup and load cycle is only necessary for local models.
                if selectedModel.provider == ModelProvider.local {
                    // Unload any previously loaded model to free up memory.
                    await whisperState.cleanupModelResources()
                    
                    // Load the new local model into memory.
                    if let localModel = await whisperState.availableModels.first(where: { $0.name == selectedModel.name }) {
                        do {
                            try await whisperState.loadModel(localModel)
                            logger.info("✅ Power Mode: Successfully loaded local model '\(localModel.name)'.")
                        } catch {
                            logger.error("❌ Power Mode: Failed to load local model '\(localModel.name)': \(error.localizedDescription)")
                        }
                    }
                } else {
                    // For cloud models, no in-memory loading is needed, but we should still
                    // clean up if the *previous* model was a local one.
                    await whisperState.cleanupModelResources()
                    logger.info("✅ Power Mode: Switched to cloud model '\(selectedModel.name)'. No local load needed.")
                }
            }
        }
        
        // Wait for UI changes and model loading to complete first
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Then check if we should capture
        if config.isAIEnhancementEnabled && config.useScreenCapture {
            await enhancementService.captureScreenContext()
=======

        if configToApply == nil {
            configToApply = PowerModeManager.shared.getConfigurationForApp(bundleIdentifier)
        }

        if configToApply == nil {
            configToApply = PowerModeManager.shared.getDefaultConfiguration()
        }

        if let config = configToApply {
            await MainActor.run {
                PowerModeManager.shared.setActiveConfiguration(config)
            }
            await PowerModeSessionManager.shared.beginSession(with: config)
        } else {
            // If no config found, keep the current active configuration (don't clear it)
>>>>>>> upstream/main
        }
    }
} 
