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
            Text("Control how VoiceInk handles your transcription data and audio recordings for privacy and storage management.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Toggle("Automatically delete transcript history", isOn: $isTranscriptionCleanupEnabled)
                .toggleStyle(.switch)
                .padding(.vertical, 4)
            
            if isTranscriptionCleanupEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Delete transcripts older than", selection: $transcriptionRetentionMinutes) {
                        Text("Immediately").tag(0)
                        Text("1 hour").tag(60)
                        Text("1 day").tag(24 * 60)
                        Text("3 days").tag(3 * 24 * 60)
                        Text("7 days").tag(7 * 24 * 60)
                    }
                    .pickerStyle(.menu)

                    Text("Older transcripts will be deleted automatically based on your selection.")
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
                            Text("Run Transcript Cleanup Now")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .alert("Transcript Cleanup", isPresented: $showTranscriptCleanupResult) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Cleanup triggered. Old transcripts are cleaned up according to your retention setting.")
                    }
                }
                .padding(.vertical, 4)
            }

            if !isTranscriptionCleanupEnabled {
                Toggle("Enable automatic audio cleanup", isOn: $isAudioCleanupEnabled)
                    .toggleStyle(.switch)
                    .padding(.vertical, 4)
            }

            if isAudioCleanupEnabled && !isTranscriptionCleanupEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Keep audio files for", selection: $audioRetentionPeriod) {
                        Text("1 day").tag(1)
                        Text("3 days").tag(3)
                        Text("7 days").tag(7)
                        Text("14 days").tag(14)
                        Text("30 days").tag(30)
                    }
                    .pickerStyle(.menu)
                    
                    Text("Audio files older than the selected period will be automatically deleted, while keeping the text transcripts intact.")
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
                        Text(isPerformingCleanup ? "Analyzing..." : "Run Cleanup Now")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isPerformingCleanup)
                .alert("Audio Cleanup", isPresented: $isShowingConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    
                    if cleanupInfo.fileCount > 0 {
                        Button("Delete \(cleanupInfo.fileCount) Files", role: .destructive) {
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
                            Text("This will delete \(cleanupInfo.fileCount) audio files older than \(audioRetentionPeriod) day\(audioRetentionPeriod > 1 ? "s" : "").")
                            Text("Total size to be freed: \(AudioCleanupManager.shared.formatFileSize(cleanupInfo.totalSize))")
                            Text("The text transcripts will be preserved.")
                        } else {
                            Text("No audio files found that are older than \(audioRetentionPeriod) day\(audioRetentionPeriod > 1 ? "s" : "").")
                        }
                    }
                }
                .alert("Cleanup Complete", isPresented: $showResultAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    if cleanupResult.errorCount > 0 {
                        Text("Successfully deleted \(cleanupResult.deletedCount) audio files. Failed to delete \(cleanupResult.errorCount) files.")
                    } else {
                        Text("Successfully deleted \(cleanupResult.deletedCount) audio files.")
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
} 