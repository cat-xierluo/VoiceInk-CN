import Foundation
import os
import Zip
import SwiftUI
<<<<<<< HEAD
=======
import Atomics
>>>>>>> upstream/main


struct WhisperModel: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    var coreMLEncoderURL: URL? // Path to the unzipped .mlmodelc directory
    var isCoreMLDownloaded: Bool { coreMLEncoderURL != nil }
    
    var downloadURL: String {
        "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(filename)"
    }
    
    var filename: String {
        "\(name).bin"
    }
    
    // Core ML related properties
    var coreMLZipDownloadURL: String? {
        // Only non-quantized models have Core ML versions
        guard !name.contains("q5") && !name.contains("q8") else { return nil }
        return "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(name)-encoder.mlmodelc.zip"
    }
    
    var coreMLEncoderDirectoryName: String? {
        guard coreMLZipDownloadURL != nil else { return nil }
        return "\(name)-encoder.mlmodelc"
    }
}

private class TaskDelegate: NSObject, URLSessionTaskDelegate {
    private let continuation: CheckedContinuation<Void, Never>
<<<<<<< HEAD
    
    init(_ continuation: CheckedContinuation<Void, Never>) {
        self.continuation = continuation
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        continuation.resume()
=======
    private let finished = ManagedAtomic(false)

    init(_ continuation: CheckedContinuation<Void, Never>) {
        self.continuation = continuation
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Ensure continuation is resumed only once, even if called multiple times
        if finished.exchange(true, ordering: .acquiring) == false {
            continuation.resume()
        }
>>>>>>> upstream/main
    }
}

// MARK: - Model Management Extension
extension WhisperState {

    
    
    // MARK: - Model Directory Management
    
    func createModelsDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            logError("Error creating models directory", error)
        }
    }
    
    func loadAvailableModels() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: modelsDirectory, includingPropertiesForKeys: nil)
            availableModels = fileURLs.compactMap { url in
                guard url.pathExtension == "bin" else { return nil }
                return WhisperModel(name: url.deletingPathExtension().lastPathComponent, url: url)
            }
        } catch {
            logError("Error loading available models", error)
        }
    }
    
    // MARK: - Model Loading
    
    func loadModel(_ model: WhisperModel) async throws {
        guard whisperContext == nil else { return }
        
        isModelLoading = true
        defer { isModelLoading = false }
        
        do {
            whisperContext = try await WhisperContext.createContext(path: model.url.path)
            
            // Set the prompt from UserDefaults to ensure we have the latest
            let currentPrompt = UserDefaults.standard.string(forKey: "TranscriptionPrompt") ?? whisperPrompt.transcriptionPrompt
            await whisperContext?.setPrompt(currentPrompt)
            
            isModelLoaded = true
            loadedLocalModel = model
        } catch {
            throw WhisperStateError.modelLoadFailed
        }
    }
    
    // MARK: - Model Download & Management
    
    /// Helper function to download a file from a URL with progress tracking
    private func downloadFileWithProgress(from url: URL, progressKey: String) async throws -> Data {
        let destinationURL = modelsDirectory.appendingPathComponent(UUID().uuidString)
<<<<<<< HEAD
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let tempURL = tempURL else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                do {
                    // Move the downloaded file to the final destination
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    
                    // Read the file in chunks to avoid memory pressure
                    let data = try Data(contentsOf: destinationURL, options: .mappedIfSafe)
                    continuation.resume(returning: data)
                    
                    // Clean up the temporary file
                    try? FileManager.default.removeItem(at: destinationURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
            
            var lastUpdateTime = Date()
            var lastProgressValue: Double = 0
            
=======

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            // Guard to prevent double resume
            let finished = ManagedAtomic(false)

            func finishOnce(_ result: Result<Data, Error>) {
                if finished.exchange(true, ordering: .acquiring) == false {
                    continuation.resume(with: result)
                }
            }

            let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    finishOnce(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let tempURL = tempURL else {
                    finishOnce(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    // Move the downloaded file to the final destination
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)

                    // Read the file in chunks to avoid memory pressure
                    let data = try Data(contentsOf: destinationURL, options: .mappedIfSafe)
                    finishOnce(.success(data))

                    // Clean up the temporary file
                    try? FileManager.default.removeItem(at: destinationURL)
                } catch {
                    finishOnce(.failure(error))
                }
            }

            task.resume()

            var lastUpdateTime = Date()
            var lastProgressValue: Double = 0

>>>>>>> upstream/main
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                let currentTime = Date()
                let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdateTime)
                let currentProgress = round(progress.fractionCompleted * 100) / 100
<<<<<<< HEAD
                
                if timeSinceLastUpdate >= 0.5 && abs(currentProgress - lastProgressValue) >= 0.01 {
                    lastUpdateTime = currentTime
                    lastProgressValue = currentProgress
                    
=======

                if timeSinceLastUpdate >= 0.5 && abs(currentProgress - lastProgressValue) >= 0.01 {
                    lastUpdateTime = currentTime
                    lastProgressValue = currentProgress

>>>>>>> upstream/main
                    DispatchQueue.main.async {
                        self.downloadProgress[progressKey] = currentProgress
                    }
                }
            }
<<<<<<< HEAD
            
            Task {
                await withTaskCancellationHandler {
                    observation.invalidate()
=======

            Task {
                await withTaskCancellationHandler {
                    observation.invalidate()
                    // Also ensure continuation is resumed with cancellation if task is cancelled
                    if finished.exchange(true, ordering: .acquiring) == false {
                        continuation.resume(throwing: CancellationError())
                    }
>>>>>>> upstream/main
                } operation: {
                    await withCheckedContinuation { (_: CheckedContinuation<Void, Never>) in }
                }
            }
        }
    }
<<<<<<< HEAD
    
    // Shows an alert about Core ML support and first-run optimization
    private func showCoreMLAlert(for model: LocalModel, completion: @escaping () -> Void) {
        Task { @MainActor in
            let alert = NSAlert()
            alert.messageText = "Core ML Support for \(model.displayName) Model"
            alert.informativeText = "This Whisper model supports Core ML, which can improve performance by 2-4x on Apple Silicon devices.\n\nDuring the first run, it can take several minutes to optimize the model for your system. Subsequent runs will be much faster."
            alert.alertStyle = .informational
alert.addButton(withTitle: NSLocalizedString("Download", comment: "Download"))
alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                completion()
            }
        }
    }
    
    func downloadModel(_ model: LocalModel) async {
        guard let url = URL(string: model.downloadURL) else { return }
        
        // Check if model supports Core ML (non-quantized models)
        let supportsCoreML = !model.name.contains("q5") && !model.name.contains("q8")
        
        if supportsCoreML {
            // Show the CoreML alert for models that support it
            await MainActor.run {
                showCoreMLAlert(for: model) {
                    // This completion handler is called when user clicks "Download"
                    Task {
                        await self.performModelDownload(model, url)
                    }
                }
            }
        } else {
            // Directly download the model if it doesn't support Core ML
            await performModelDownload(model, url)
        }
=======
    func downloadModel(_ model: LocalModel) async {
        guard let url = URL(string: model.downloadURL) else { return }
        await performModelDownload(model, url)
>>>>>>> upstream/main
    }
    
    private func performModelDownload(_ model: LocalModel, _ url: URL) async {
        do {
<<<<<<< HEAD
            let whisperModel = try await downloadMainModel(model, from: url)
            
            if let coreMLZipURL = whisperModel.coreMLZipDownloadURL,
               let coreMLURL = URL(string: coreMLZipURL) {
                try await downloadAndSetupCoreMLModel(for: whisperModel, from: coreMLURL)
=======
            var whisperModel = try await downloadMainModel(model, from: url)
            
            if let coreMLZipURL = whisperModel.coreMLZipDownloadURL,
               let coreMLURL = URL(string: coreMLZipURL) {
                whisperModel = try await downloadAndSetupCoreMLModel(for: whisperModel, from: coreMLURL)
>>>>>>> upstream/main
            }
            
            availableModels.append(whisperModel)
            self.downloadProgress.removeValue(forKey: model.name + "_main")
<<<<<<< HEAD
=======

            if shouldWarmup(model) {
                WhisperModelWarmupCoordinator.shared.scheduleWarmup(for: model, whisperState: self)
            }
>>>>>>> upstream/main
        } catch {
            handleModelDownloadError(model, error)
        }
    }
    
    private func downloadMainModel(_ model: LocalModel, from url: URL) async throws -> WhisperModel {
        let progressKeyMain = model.name + "_main"
        let data = try await downloadFileWithProgress(from: url, progressKey: progressKeyMain)
        
        let destinationURL = modelsDirectory.appendingPathComponent(model.filename)
        try data.write(to: destinationURL)
        
        return WhisperModel(name: model.name, url: destinationURL)
    }
    
<<<<<<< HEAD
    private func downloadAndSetupCoreMLModel(for model: WhisperModel, from url: URL) async throws {
=======
    private func downloadAndSetupCoreMLModel(for model: WhisperModel, from url: URL) async throws -> WhisperModel {
>>>>>>> upstream/main
        let progressKeyCoreML = model.name + "_coreml"
        let coreMLData = try await downloadFileWithProgress(from: url, progressKey: progressKeyCoreML)
        
        let coreMLZipPath = modelsDirectory.appendingPathComponent("\(model.name)-encoder.mlmodelc.zip")
        try coreMLData.write(to: coreMLZipPath)
        
<<<<<<< HEAD
        try await unzipAndSetupCoreMLModel(for: model, zipPath: coreMLZipPath, progressKey: progressKeyCoreML)
    }
    
    private func unzipAndSetupCoreMLModel(for model: WhisperModel, zipPath: URL, progressKey: String) async throws {
=======
        return try await unzipAndSetupCoreMLModel(for: model, zipPath: coreMLZipPath, progressKey: progressKeyCoreML)
    }
    
    private func unzipAndSetupCoreMLModel(for model: WhisperModel, zipPath: URL, progressKey: String) async throws -> WhisperModel {
>>>>>>> upstream/main
        let coreMLDestination = modelsDirectory.appendingPathComponent("\(model.name)-encoder.mlmodelc")
        
        try? FileManager.default.removeItem(at: coreMLDestination)
        try await unzipCoreMLFile(zipPath, to: modelsDirectory)
<<<<<<< HEAD
        try verifyAndCleanupCoreMLFiles(model, coreMLDestination, zipPath, progressKey)
    }
    
    private func unzipCoreMLFile(_ zipPath: URL, to destination: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
                try Zip.unzipFile(zipPath, destination: destination, overwrite: true, password: nil)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
=======
        return try verifyAndCleanupCoreMLFiles(model, coreMLDestination, zipPath, progressKey)
    }
    
    private func unzipCoreMLFile(_ zipPath: URL, to destination: URL) async throws {
        let finished = ManagedAtomic(false)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            func finishOnce(_ result: Result<Void, Error>) {
                if finished.exchange(true, ordering: .acquiring) == false {
                    continuation.resume(with: result)
                }
            }

            do {
                try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
                try Zip.unzipFile(zipPath, destination: destination, overwrite: true, password: nil)
                finishOnce(.success(()))
            } catch {
                finishOnce(.failure(error))
>>>>>>> upstream/main
            }
        }
    }
    
    private func verifyAndCleanupCoreMLFiles(_ model: WhisperModel, _ destination: URL, _ zipPath: URL, _ progressKey: String) throws -> WhisperModel {
        var model = model
        
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            try? FileManager.default.removeItem(at: zipPath)
            throw WhisperStateError.unzipFailed
        }
        
        try? FileManager.default.removeItem(at: zipPath)
        model.coreMLEncoderURL = destination
        self.downloadProgress.removeValue(forKey: progressKey)
        
        return model
    }
<<<<<<< HEAD
=======

    private func shouldWarmup(_ model: LocalModel) -> Bool {
        !model.name.contains("q5") && !model.name.contains("q8")
    }
>>>>>>> upstream/main
    
    private func handleModelDownloadError(_ model: LocalModel, _ error: Error) {
        self.downloadProgress.removeValue(forKey: model.name + "_main")
        self.downloadProgress.removeValue(forKey: model.name + "_coreml")
    }
    
    func deleteModel(_ model: WhisperModel) async {
        do {
            // Delete main model file
            try FileManager.default.removeItem(at: model.url)
            
            // Delete CoreML model if it exists
            if let coreMLURL = model.coreMLEncoderURL {
                try? FileManager.default.removeItem(at: coreMLURL)
            } else {
                // Check if there's a CoreML directory matching the model name
                let coreMLDir = modelsDirectory.appendingPathComponent("\(model.name)-encoder.mlmodelc")
                if FileManager.default.fileExists(atPath: coreMLDir.path) {
                    try? FileManager.default.removeItem(at: coreMLDir)
                }
            }
            
            // Update model state
            availableModels.removeAll { $0.id == model.id }
            if currentTranscriptionModel?.name == model.name {

                currentTranscriptionModel = nil
                UserDefaults.standard.removeObject(forKey: "CurrentTranscriptionModel")

                loadedLocalModel = nil
                recordingState = .idle
                UserDefaults.standard.removeObject(forKey: "CurrentModel")
            }
        } catch {
            logError("Error deleting model: \(model.name)", error)
        }
<<<<<<< HEAD
=======

        // Ensure UI reflects removal of imported models as well
        await MainActor.run {
            self.refreshAllAvailableModels()
        }
>>>>>>> upstream/main
    }
    
    func unloadModel() {
        Task {
            await whisperContext?.releaseResources()
            whisperContext = nil
            isModelLoaded = false
            
            if let recordedFile = recordedFile {
                try? FileManager.default.removeItem(at: recordedFile)
                self.recordedFile = nil
            }
        }
    }
    
    func clearDownloadedModels() async {
        for model in availableModels {
            do {
                try FileManager.default.removeItem(at: model.url)
            } catch {
                logError("Error deleting model during cleanup", error)
            }
        }
        availableModels.removeAll()
    }
    
    // MARK: - Resource Management
    
    func cleanupModelResources() async {
        await whisperContext?.releaseResources()
        whisperContext = nil
        isModelLoaded = false
<<<<<<< HEAD
=======

        parakeetTranscriptionService.cleanup()
>>>>>>> upstream/main
    }
    
    // MARK: - Helper Methods
    
    private func logError(_ message: String, _ error: Error) {
        self.logger.error("\(message): \(error.localizedDescription)")
    }
<<<<<<< HEAD
=======

    // MARK: - Import Local Model (User-provided .bin)

    @MainActor
    func importLocalModel(from sourceURL: URL) async {
        // Accept only .bin files for ggml Whisper models
        guard sourceURL.pathExtension.lowercased() == "bin" else { return }

        // Build a destination URL inside the app-managed models directory
        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        var destinationURL = modelsDirectory.appendingPathComponent("\(baseName).bin")

        // Do not rename on collision; simply notify the user and abort
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            await NotificationManager.shared.showNotification(
                title: "A model named \(baseName).bin already exists",
                type: .warning,
                duration: 4.0
            )
            return
        }

        do {
            try FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

            // Append ONLY the newly imported model to in-memory lists (no full rescan)
            let newWhisperModel = WhisperModel(name: baseName, url: destinationURL)
            availableModels.append(newWhisperModel)

            if !allAvailableModels.contains(where: { $0.name == baseName }) {
                let imported = ImportedLocalModel(fileBaseName: baseName)
                allAvailableModels.append(imported)
            }

            await NotificationManager.shared.showNotification(
                title: "Imported \(destinationURL.lastPathComponent)",
                type: .success,
                duration: 3.0
            )
        } catch {
            logError("Failed to import local model", error)
            await NotificationManager.shared.showNotification(
                title: "Failed to import model: \(error.localizedDescription)",
                type: .error,
                duration: 5.0
            )
        }
    }
>>>>>>> upstream/main
}

// MARK: - Download Progress View
struct DownloadProgressView: View {
    let modelName: String
    let downloadProgress: [String: Double]
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var mainProgress: Double {
        downloadProgress[modelName + "_main"] ?? 0
    }
    
    private var coreMLProgress: Double {
        supportsCoreML ? (downloadProgress[modelName + "_coreml"] ?? 0) : 0
    }
    
    private var supportsCoreML: Bool {
        !modelName.contains("q5") && !modelName.contains("q8")
    }
    
    private var totalProgress: Double {
        supportsCoreML ? (mainProgress * 0.5) + (coreMLProgress * 0.5) : mainProgress
    }
    
    private var downloadPhase: String {
        // Check if we're currently downloading the CoreML model
        if supportsCoreML && downloadProgress[modelName + "_coreml"] != nil {
<<<<<<< HEAD
            return NSLocalizedString("Downloading Core ML Model for \(modelName)", comment: "Downloading Core ML Model for \(modelName)")
        }
        // Otherwise, we're downloading the main model
        return NSLocalizedString("Downloading \(modelName) Model", comment: "Downloading \(modelName) Model")
=======
            return "Downloading Core ML Model for \(modelName)"
        }
        // Otherwise, we're downloading the main model
        return "Downloading \(modelName) Model"
>>>>>>> upstream/main
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status text with clean typography
            Text(downloadPhase)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(.secondaryLabelColor))
            
            // Clean progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.separatorColor).opacity(0.3))
                        .frame(height: 6)
                    
                    // Progress indicator
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.controlAccentColor))
                        .frame(width: max(0, min(geometry.size.width * totalProgress, geometry.size.width)), height: 6)
                }
            }
            .frame(height: 6)
            
            // Percentage indicator in Apple style
            HStack {
                Spacer()
<<<<<<< HEAD
                Text(NSLocalizedString("\(Int(totalProgress * 100))%", comment: "\(Int(totalProgress * 100))%"))
=======
                Text("\(Int(totalProgress * 100))%")
>>>>>>> upstream/main
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(.secondaryLabelColor))
            }
        }
        .padding(.vertical, 4)
        .animation(.smooth, value: totalProgress)
    }
} 
