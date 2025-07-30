import SwiftUI
import SwiftData

struct TranscriptionCard: View {
    let transcription: Transcription
    let isExpanded: Bool
    let isSelected: Bool
    let onDelete: () -> Void
    let onToggleSelection: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox in macOS style
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggleSelection() }
            ))
            .toggleStyle(CircularCheckboxStyle())
            .labelsHidden()
            
            VStack(alignment: .leading, spacing: 8) {
                // Header with date and duration
                HStack {
                    Text(transcription.timestamp, format: .dateTime.month(.abbreviated).day().year().hour().minute())
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    Text(formatTiming(transcription.duration))
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                // Original text section
                VStack(alignment: .leading, spacing: 8) {
                    Text(transcription.text)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .lineLimit(isExpanded ? nil : 2)
                        .lineSpacing(2)
                    
                    if isExpanded {
                        HStack {
                            Text("Original")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            AnimatedCopyButton(textToCopy: transcription.text)
                        }
                    }
                }
                
                // Enhanced text section (only when expanded)
                if isExpanded, let enhancedText = transcription.enhancedText {
                    Divider()
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(enhancedText)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .lineSpacing(2)
                        
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.blue)
                                Text("Enhanced")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            AnimatedCopyButton(textToCopy: enhancedText)
                        }
                    }
                }
                
                // Audio player (if available)
                if isExpanded, let urlString = transcription.audioFileURL,
                   let url = URL(string: urlString),
                   FileManager.default.fileExists(atPath: url.path) {
                    Divider()
                        .padding(.vertical, 8)
                    AudioPlayerView(url: url)
                }
                
                // Metadata section (when expanded)
                if isExpanded && hasMetadata {
                    Divider()
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        metadataRow(icon: "hourglass", label: "Audio Duration", value: formatTiming(transcription.duration))
                        if let modelName = transcription.transcriptionModelName {
                            metadataRow(icon: "cpu.fill", label: "Transcription Model", value: modelName)
                        }
                        if let aiModel = transcription.aiEnhancementModelName {
                            metadataRow(icon: "sparkles", label: "Enhancement Model", value: aiModel)
                        }
                        if let duration = transcription.transcriptionDuration {
                            metadataRow(icon: "clock.fill", label: "Transcription Time", value: formatTiming(duration))
                        }
                        if let duration = transcription.enhancementDuration {
                            metadataRow(icon: "clock.fill", label: "Enhancement Time", value: formatTiming(duration))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(CardBackground(isSelected: false))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .contextMenu {
            if let enhancedText = transcription.enhancedText {
                Button {
                    let _ = ClipboardManager.copyToClipboard(enhancedText)
                } label: {
                    Label("Copy Enhanced", systemImage: "doc.on.doc")
                }
            }
            
            Button {
                let _ = ClipboardManager.copyToClipboard(transcription.text)
            } label: {
                Label("Copy Original", systemImage: "doc.on.doc")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var hasMetadata: Bool {
        transcription.transcriptionModelName != nil ||
        transcription.aiEnhancementModelName != nil ||
        transcription.transcriptionDuration != nil ||
        transcription.enhancementDuration != nil
    }
    
    private func formatTiming(_ duration: TimeInterval) -> String {
        if duration < 1 {
            return String(format: "%.0fms", duration * 1000)
        }
        if duration < 60 {
            return String(format: "%.1fs", duration)
        }
        let minutes = Int(duration) / 60
        let seconds = duration.truncatingRemainder(dividingBy: 60)
        return String(format: "%dm %.0fs", minutes, seconds)
    }
    
    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .center)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }
}
