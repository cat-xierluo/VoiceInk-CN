import SwiftUI
import SwiftData

struct AudioCleanupSettingsView: View {
    @EnvironmentObject private var whisperState: WhisperState
    
    // Audio cleanup settings
    @AppStorage("IsTranscriptionCleanupEnabled") private var isTranscriptionCleanupEnabled = false
    @AppStorage("TranscriptionRetentionMinutes") private var transcriptionRetentionMinutes = 24 * 60
    @AppStorage("IsAudioCleanupEnabled") private var isAudioCleanupEnabled = false
    @AppStorage("AudioRetentionPeriod") private var audioRetentionPeriod = 7
    @State private var isPerformingCleanup = false
    @State private var isShowingConfirmation = false
    @State private var cleanupInfo: (fileCount: Int, totalSize: Int64, transcriptions: [Transcription]) = (0, 0, [])
    @State private var showResultAlert = false
    @State private var cleanupResult: (deletedCount: Int, errorCount: Int) = (0, 0)
    @State private var showTranscriptCleanupResult = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.SettingsExtended.AudioCleanup.title.text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Toggle(L10n.SettingsExtended.AudioCleanup.transcriptCleanupToggle.text, isOn: $isTranscriptionCleanupEnabled)
                .toggleStyle(.switch)
                .padding(.vertical, 4)

            if isTranscriptionCleanupEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Picker(L10n.SettingsExtended.AudioCleanup.deleteTranscriptsOlderThan.text, selection: $transcriptionRetentionMinutes) {
                        Text(L10n.SettingsExtended.AudioCleanup.immediate.text).tag(0)
                        Text(L10n.SettingsExtended.AudioCleanup.oneHour.text).tag(60)
                        Text(L10n.SettingsExtended.AudioCleanup.oneDay.text).tag(24 * 60)
                        Text(L10n.SettingsExtended.AudioCleanup.threeDays.text).tag(3 * 24 * 60)
                        Text(L10n.SettingsExtended.AudioCleanup.sevenDays.text).tag(7 * 24 * 60)
                    }
                    .pickerStyle(.menu)

                    Text(L10n.SettingsExtended.AudioCleanup.retentionDescription.text)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)

                    Button(action: {
                        Task {
                            await TranscriptionAutoCleanupService.shared.runManualCleanup(modelContext: whisperState.modelContext)
                            await MainActor.run {
                                showTranscriptCleanupResult = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash.circle")
                            Text(L10n.SettingsExtended.AudioCleanup.runCleanupNow.text)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .alert(L10n.SettingsExtended.AudioCleanup.transcriptCleanupAlertTitle.text, isPresented: $showTranscriptCleanupResult) {
                        Button(L10n.Common.ok.text, role: .cancel) { }
                    } message: {
                        Text(L10n.SettingsExtended.AudioCleanup.cleanupTriggered.text)
                    }
                }
                .padding(.vertical, 4)
            }

            if !isTranscriptionCleanupEnabled {
                Toggle(L10n.SettingsExtended.AudioCleanup.enableAudioCleanup.text, isOn: $isAudioCleanupEnabled)
                    .toggleStyle(.switch)
                    .padding(.vertical, 4)
            }

            if isAudioCleanupEnabled && !isTranscriptionCleanupEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Picker(L10n.SettingsExtended.AudioCleanup.keepAudioFilesFor.text, selection: $audioRetentionPeriod) {
                        Text(L10n.SettingsExtended.AudioCleanup.oneDay.text).tag(1)
                        Text(L10n.SettingsExtended.AudioCleanup.threeDays.text).tag(3)
                        Text(L10n.SettingsExtended.AudioCleanup.sevenDays.text).tag(7)
                        Text(L10n.SettingsExtended.AudioCleanup.fourteenDays.text).tag(14)
                        Text(L10n.SettingsExtended.AudioCleanup.thirtyDays.text).tag(30)
                    }
                    .pickerStyle(.menu)

                    Text(L10n.SettingsExtended.AudioCleanup.audioCleanupDescription.text)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
                .padding(.vertical, 4)
                
                Button(action: {
                    // Start by analyzing what would be cleaned up
                    Task {
                        // Update UI state
                        await MainActor.run {
                            isPerformingCleanup = true
                        }
                        
                        // Get cleanup info
                        let info = await AudioCleanupManager.shared.getCleanupInfo(modelContext: whisperState.modelContext)
                        
                        // Update UI with results
                        await MainActor.run {
                            cleanupInfo = info
                            isPerformingCleanup = false
                            isShowingConfirmation = true
                        }
                    }
                }) {
                    HStack {
                        if isPerformingCleanup {
                            ProgressView()
                                .controlSize(.small)
                                .padding(.trailing, 4)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(isPerformingCleanup ? L10n.SettingsExtended.AudioCleanup.analyzing.text : L10n.SettingsExtended.AudioCleanup.runCleanupNow.text)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isPerformingCleanup)
                .alert(L10n.SettingsExtended.AudioCleanup.audioCleanupAlertTitle.text, isPresented: $isShowingConfirmation) {
                    Button(L10n.Common.cancel.text, role: .cancel) { }

                    if cleanupInfo.fileCount > 0 {
                        Button(String(format: L10n.SettingsExtended.AudioCleanup.deleteFiles.string, cleanupInfo.fileCount), role: .destructive) {
                            Task {
                                // Update UI state
                                await MainActor.run {
                                    isPerformingCleanup = true
                                }
                                
                                // Perform cleanup
                                let result = await AudioCleanupManager.shared.runCleanupForTranscriptions(
                                    modelContext: whisperState.modelContext, 
                                    transcriptions: cleanupInfo.transcriptions
                                )
                                
                                // Update UI with results
                                await MainActor.run {
                                    cleanupResult = result
                                    isPerformingCleanup = false
                                    showResultAlert = true
                                }
                            }
                        }
                    }
                } message: {
                    VStack(alignment: .leading, spacing: 8) {
                        if cleanupInfo.fileCount > 0 {
                            let retentionLabel = retentionDescription(for: audioRetentionPeriod)
                            Text(String(format: L10n.SettingsExtended.AudioCleanup.confirmCleanup.string, cleanupInfo.fileCount, retentionLabel))
                            Text(String(format: L10n.SettingsExtended.AudioCleanup.totalSizeToFree.string, AudioCleanupManager.shared.formatFileSize(cleanupInfo.totalSize)))
                            Text(L10n.SettingsExtended.AudioCleanup.transcriptsPreserved.text)
                        } else {
                            let retentionLabel = retentionDescription(for: audioRetentionPeriod)
                            Text(String(format: L10n.SettingsExtended.AudioCleanup.noFilesToDelete.string, retentionLabel))
                        }
                    }
                }
                .alert(L10n.SettingsExtended.AudioCleanup.cleanupCompleteTitle.text, isPresented: $showResultAlert) {
                    Button(L10n.Common.ok.text, role: .cancel) { }
                } message: {
                    if cleanupResult.errorCount > 0 {
                        Text(String(format: L10n.SettingsExtended.AudioCleanup.cleanupSuccess.string, cleanupResult.deletedCount, cleanupResult.errorCount))
                    } else {
                        Text(String(format: L10n.SettingsExtended.AudioCleanup.cleanupSuccessSimple.string, cleanupResult.deletedCount))
                    }
                }
            }
        }
        .onChange(of: isTranscriptionCleanupEnabled) { _, newValue in
            if newValue {
                AudioCleanupManager.shared.stopAutomaticCleanup()
            } else if isAudioCleanupEnabled {
                AudioCleanupManager.shared.startAutomaticCleanup(modelContext: whisperState.modelContext)
            }
        }
    }
    
    private func retentionDescription(for days: Int) -> String {
        String(format: L10n.SettingsExtended.AudioCleanup.dayCount.string, days)
    }
} 
