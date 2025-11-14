import Foundation
import SwiftData
import OSLog

class TranscriptionAutoCleanupService {
    static let shared = TranscriptionAutoCleanupService()

    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "TranscriptionAutoCleanupService")
    private var modelContext: ModelContext?

    private let keyIsEnabled = "IsTranscriptionCleanupEnabled"
    private let keyRetentionMinutes = "TranscriptionRetentionMinutes"

    private let defaultRetentionMinutes: Int = 24 * 60

    private init() {}

    func startMonitoring(modelContext: ModelContext) {
        self.modelContext = modelContext

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTranscriptionCompleted(_:)),
            name: .transcriptionCompleted,
            object: nil
        )

        if UserDefaults.standard.bool(forKey: keyIsEnabled) {
            
            Task { [weak self] in
                guard let self = self, let modelContext = self.modelContext else { return }
                await self.sweepOldTranscriptions(modelContext: modelContext)
            }
        } else {}
    }

    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: .transcriptionCompleted, object: nil)
    }

    func runManualCleanup(modelContext: ModelContext) async {
        await sweepOldTranscriptions(modelContext: modelContext)
    }

    @objc private func handleTranscriptionCompleted(_ notification: Notification) {
        let isEnabled = UserDefaults.standard.bool(forKey: keyIsEnabled)
        guard isEnabled else { return }

        let minutes = UserDefaults.standard.integer(forKey: keyRetentionMinutes)
        if minutes > 0 {
            // Trigger a sweep based on the retention window
            if let modelContext = self.modelContext {
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.sweepOldTranscriptions(modelContext: modelContext)
                }
            }
            return
        }

        guard let transcription = notification.object as? Transcription,
              let modelContext = self.modelContext else {
            logger.error("Invalid transcription or missing model context")
            return
        }

        if let urlString = transcription.audioFileURL,
           let url = URL(string: urlString) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                logger.error("Failed to delete audio file: \(error.localizedDescription)")
            }
        }

        modelContext.delete(transcription)

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save after transcription deletion: \(error.localizedDescription)")
        }
    }

    private func sweepOldTranscriptions(modelContext: ModelContext) async {
        guard UserDefaults.standard.bool(forKey: keyIsEnabled) else {
            return
        }

        let retentionMinutes = UserDefaults.standard.integer(forKey: keyRetentionMinutes)
        let effectiveMinutes = max(retentionMinutes, 0)

        let cutoffDate = Date().addingTimeInterval(TimeInterval(-effectiveMinutes * 60))

        do {
            try await MainActor.run {
                let descriptor = FetchDescriptor<Transcription>(
                    predicate: #Predicate<Transcription> { transcription in
                        transcription.timestamp < cutoffDate
                    }
                )
                let items = try modelContext.fetch(descriptor)
                var deletedCount = 0
                for transcription in items {
                    // Remove audio file if present
                    if let urlString = transcription.audioFileURL,
                       let url = URL(string: urlString),
                       FileManager.default.fileExists(atPath: url.path) {
                        try? FileManager.default.removeItem(at: url)
                    }
                    modelContext.delete(transcription)
                    deletedCount += 1
                }
                if deletedCount > 0 { try modelContext.save() }
            }
        } catch {
            logger.error("Failed during transcription cleanup: \(error.localizedDescription)")
        }
    }
}