import Foundation
import AVFoundation
import os

class LocalTranscriptionService: TranscriptionService {
    
    private var whisperContext: WhisperContext?
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "LocalTranscriptionService")
    private let modelsDirectory: URL
    private weak var whisperState: WhisperState?
    
    init(modelsDirectory: URL, whisperState: WhisperState? = nil) {
        self.modelsDirectory = modelsDirectory
        self.whisperState = whisperState
    }
    
    func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        guard let localModel = model as? LocalModel else {
            throw WhisperStateError.modelLoadFailed
        }
        
        logger.notice("Initiating local transcription for model: \(localModel.displayName)")
        
        // Check if the required model is already loaded in WhisperState
        if let whisperState = whisperState,
           await whisperState.isModelLoaded,
           let loadedContext = await whisperState.whisperContext,
           let currentModel = await whisperState.currentTranscriptionModel,
           currentModel.provider == .local,
           currentModel.name == localModel.name {
            
            logger.notice("✅ Using already loaded model: \(localModel.name)")
            whisperContext = loadedContext
        } else {
            // Model not loaded or wrong model loaded, proceed with loading
            let modelURL = modelsDirectory.appendingPathComponent(localModel.filename)
            
            guard FileManager.default.fileExists(atPath: modelURL.path) else {
                logger.error("Model file not found at path: \(modelURL.path)")
                throw WhisperStateError.modelLoadFailed
            }
            
            logger.notice("Loading model: \(localModel.name)")
            do {
                whisperContext = try await WhisperContext.createContext(path: modelURL.path)
            } catch {
                logger.error("Failed to load model: \(localModel.name) - \(error.localizedDescription)")
                throw WhisperStateError.modelLoadFailed
            }
        }
        
        guard let whisperContext = whisperContext else {
            logger.error("Cannot transcribe: Model could not be loaded")
            throw WhisperStateError.modelLoadFailed
        }
        
        // Read audio data
        let data = try readAudioSamples(audioURL)
        
        // Set prompt
        let currentPrompt = UserDefaults.standard.string(forKey: "TranscriptionPrompt") ?? ""
        await whisperContext.setPrompt(currentPrompt)
        
        // Transcribe
        let success = await whisperContext.fullTranscribe(samples: data)
        
        guard success else {
            logger.error("Core transcription engine failed (whisper_full).")
            throw WhisperStateError.whisperCoreFailed
        }
        
        var text = await whisperContext.getTranscription()
        
        if UserDefaults.standard.object(forKey: "IsTextFormattingEnabled") as? Bool ?? true {
            text = WhisperTextFormatter.format(text)
        }
        
        logger.notice("✅ Local transcription completed successfully.")
        
        // Only release resources if we created a new context (not using the shared one)
        if await whisperState?.whisperContext !== whisperContext {
            await whisperContext.releaseResources()
            self.whisperContext = nil
        }
        
        return text
    }
    
    private func readAudioSamples(_ url: URL) throws -> [Float] {
        let data = try Data(contentsOf: url)
        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }
        return floats
    }
} 