import Foundation
import AVFoundation
import FluidAudio
import os.log



class ParakeetTranscriptionService: TranscriptionService {
    private var asrManager: AsrManager?
    private let customModelsDirectory: URL?
    @Published var isModelLoaded = false
    
    // Logger for Parakeet transcription service
    private let logger = Logger(subsystem: "com.voiceink.app", category: "ParakeetTranscriptionService")
    
    init(customModelsDirectory: URL? = nil) {
        self.customModelsDirectory = customModelsDirectory
    }

    func loadModel() async throws {
        if isModelLoaded {
            return
        }

        logger.notice("🦜 Starting Parakeet model loading")
        
        do {
            let asrConfig = ASRConfig(
                maxSymbolsPerFrame: 3,
                realtimeMode: true,
                chunkSizeMs: 1500,
                tdtConfig: TdtConfig(
                    durations: [0, 1, 2, 3, 4],
                    maxSymbolsPerStep: 3
                )
            )
            asrManager = AsrManager(config: asrConfig)
            
            let models: AsrModels
            if let customDirectory = customModelsDirectory {
                models = try await AsrModels.downloadAndLoad(to: customDirectory)
            } else {
                models = try await AsrModels.downloadAndLoad()
            }
            
            try await asrManager?.initialize(models: models)
            isModelLoaded = true
            logger.notice("🦜 Parakeet model loaded successfully")
            
        } catch {
            logger.error("🦜 Failed to load Parakeet model: \(error.localizedDescription)")
            isModelLoaded = false
            asrManager = nil
            throw error
        }
    }

    func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        do {
            defer {
                asrManager?.cleanup()
                self.asrManager = nil
                self.isModelLoaded = false
            }

            if !isModelLoaded {
                try await loadModel()
            }
            
            guard let asrManager = asrManager else {
                logger.error("🦜 ASR manager is nil after model loading")
                throw NSError(domain: "ParakeetTranscriptionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize ASR manager."])
            }

            logger.notice("🦜 Starting Parakeet transcription")
            let audioSamples = try readAudioSamples(from: audioURL)
            let result = try await asrManager.transcribe(audioSamples)
            logger.notice("🦜 Parakeet transcription completed")
            
            if UserDefaults.standard.object(forKey: "IsTextFormattingEnabled") as? Bool ?? true {
                return WhisperTextFormatter.format(result.text)
            }
            return result.text
        } catch {
            logger.error("🦜 Parakeet transcription failed: \(error.localizedDescription)")
            let errorMessage = error.localizedDescription
            await MainActor.run {
                NotificationManager.shared.showNotification(
                    title: "Transcription Failed: \(errorMessage)",
                    type: .error
                )
            }
            return ""
        }
    }

    private func readAudioSamples(from url: URL) throws -> [Float] {
        let data = try Data(contentsOf: url)
        // A basic check, assuming a more robust check happens elsewhere.
        guard data.count > 44 else { return [] }

        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }
        return floats
    }
} 