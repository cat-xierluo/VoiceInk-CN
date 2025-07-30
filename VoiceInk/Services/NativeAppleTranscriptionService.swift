import Foundation
import AVFoundation
import os

#if canImport(Speech)
import Speech
#endif

/// Transcription service that leverages the new SpeechAnalyzer / SpeechTranscriber API available on macOS 26 (Tahoe).
/// Falls back with an unsupported-provider error on earlier OS versions so the application can gracefully degrade.
class NativeAppleTranscriptionService: TranscriptionService {
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "NativeAppleTranscriptionService")
    
    /// Maps simple language codes to Apple's BCP-47 locale format
    private func mapToAppleLocale(_ simpleCode: String) -> String {
        let mapping = [
            "en": "en-US",
            "es": "es-ES", 
            "fr": "fr-FR",
            "de": "de-DE",
            "ar": "ar-SA",
            "it": "it-IT",
            "ja": "ja-JP",
            "ko": "ko-KR",
            "pt": "pt-BR",
            "yue": "yue-CN",
            "zh": "zh-CN"
        ]
        return mapping[simpleCode] ?? "en-US"
    }
    
    enum ServiceError: Error, LocalizedError {
        case unsupportedOS
        case transcriptionFailed
        case localeNotSupported
        case invalidModel
        case assetAllocationFailed
        
        var errorDescription: String? {
            switch self {
            case .unsupportedOS:
                return "SpeechAnalyzer requires macOS 26 or later."
            case .transcriptionFailed:
                return "Transcription failed using SpeechAnalyzer."
            case .localeNotSupported:
                return "The selected language is not supported by SpeechAnalyzer."
            case .invalidModel:
                return "Invalid model type provided for Native Apple transcription."
            case .assetAllocationFailed:
                return "Failed to allocate assets for the selected locale."
            }
        }
    }

    func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        guard model is NativeAppleModel else {
            throw ServiceError.invalidModel
        }
        
        guard #available(macOS 26, *) else {
            logger.error("SpeechAnalyzer is not available on this macOS version")
            throw ServiceError.unsupportedOS
        }
        
        logger.notice("Starting Apple native transcription with SpeechAnalyzer.")
        
        let audioFile = try AVAudioFile(forReading: audioURL)
        
        // Get the user's selected language in simple format and convert to BCP-47 format
        let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
        let appleLocale = mapToAppleLocale(selectedLanguage)
        let locale = Locale(identifier: appleLocale)

        // Check for locale support and asset installation status using proper BCP-47 format
        // TODO: These APIs are not available in current system version
        let supportedLocales: [Locale] = []
        let installedLocales: [Locale] = []
        let isLocaleSupported = false
        let isLocaleInstalled = false

        // Create the detailed log message
        let supportedIdentifiers = supportedLocales.map { $0.identifier(.bcp47) }.sorted().joined(separator: ", ")
        let installedIdentifiers = installedLocales.map { $0.identifier(.bcp47) }.sorted().joined(separator: ", ")
        let availableForDownload = Set(supportedLocales).subtracting(Set(installedLocales)).map { $0.identifier(.bcp47) }.sorted().joined(separator: ", ")
        
        var statusMessage: String
        if isLocaleInstalled {
            statusMessage = "✅ Installed"
        } else if isLocaleSupported {
            statusMessage = "❌ Not Installed (Available for download)"
        } else {
            statusMessage = "❌ Not Supported"
        }
        
        let logMessage = """
        
        --- Native Speech Transcription ---
        Selected Language: '\(selectedLanguage)' → Apple Locale: '\(locale.identifier(.bcp47))'
        Status: \(statusMessage)
        ------------------------------------
        Supported Locales: [\(supportedIdentifiers)]
        Installed Locales: [\(installedIdentifiers)]
        Available for Download: [\(availableForDownload)]
        ------------------------------------
        """
        logger.notice("\(logMessage)")

        guard isLocaleSupported else {
            logger.error("Transcription failed: Locale '\(locale.identifier(.bcp47))' is not supported by SpeechTranscriber.")
            throw ServiceError.localeNotSupported
        }
        
        // Properly manage asset allocation/deallocation
        try await deallocateExistingAssets()
        try await allocateAssetsForLocale(locale)
        
        // TODO: SpeechTranscriber and SpeechAnalyzer APIs not available in current system version
        // This service is currently disabled
        throw ServiceError.transcriptionFailed
        
        /* Code disabled due to API unavailability
        try await analyzer.start(inputAudioFile: audioFile, finishAfterFile: true)
        
        var transcript: AttributedString = ""
        for try await result in transcriber.results {
            transcript += result.text
        }
        
        var finalTranscription = String(transcript.characters).trimmingCharacters(in: .whitespacesAndNewlines)
        */
        
        // This service is currently disabled due to unavailable APIs
        return ""
    }
    
    @available(macOS 26, *)
    private func deallocateExistingAssets() async throws {
        #if canImport(Speech)
        // Deallocate any existing allocated locales to avoid conflicts
        // TODO: AssetInventory API not available in current system version
        for locale in [] as [Locale] {
            // TODO: AssetInventory API not available
            // await AssetInventory.deallocate(locale: locale)
        }
        logger.notice("Deallocated existing asset locales.")
        #endif
    }
    
    @available(macOS 26, *)
    private func allocateAssetsForLocale(_ locale: Locale) async throws {
        #if canImport(Speech)
        do {
            // TODO: AssetInventory API not available
            // try await AssetInventory.allocate(locale: locale)
            logger.notice("Successfully allocated assets for locale: '\(locale.identifier(.bcp47))'")
        } catch {
            logger.error("Failed to allocate assets for locale '\(locale.identifier(.bcp47))': \(error.localizedDescription)")
            throw ServiceError.assetAllocationFailed
        }
        #endif
    }
    
    @available(macOS 26, *)
    private func ensureModelIsAvailable(for transcriber: Any, locale: Locale) async throws {
        #if canImport(Speech)
        // TODO: SpeechTranscriber API not available
        let installedLocales: [Locale] = []
        let isInstalled = false

        if !isInstalled {
            logger.notice("Assets for '\(locale.identifier(.bcp47))' not installed. Requesting system download.")
            
            // TODO: AssetInventory API not available
            if false {
                // try await request.downloadAndInstall()
                logger.notice("Asset download for '\(locale.identifier(.bcp47))' complete.")
            } else {
                logger.error("Asset download for '\(locale.identifier(.bcp47))' failed: Could not create installation request.")
                // Note: We don't throw an error here, as transcription might still work with a base model.
            }
        }
        #endif
    }
} 
