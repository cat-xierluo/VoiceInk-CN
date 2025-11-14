import SwiftUI
import SwiftData

enum ContentTab: String, CaseIterable {
    case original = "Original"
    case enhanced = "Enhanced"
    case aiRequest = "AI Request"

    var displayName: String {
        switch self {
        case .original: return L10n.Transcription.original.string
        case .enhanced: return L10n.Transcription.enhanced.string
        case .aiRequest: return L10n.Transcription.aiRequest.string
        }
    }
}

struct TranscriptionCard: View {
    let transcription: Transcription
    let isExpanded: Bool
    let isSelected: Bool
    let onDelete: () -> Void
    let onToggleSelection: () -> Void

    @State private var selectedTab: ContentTab = .original

    private var availableTabs: [ContentTab] {
        var tabs: [ContentTab] = []
        if transcription.enhancedText != nil {
            tabs.append(.enhanced)
        }
        tabs.append(.original)
        if transcription.aiRequestSystemMessage != nil || transcription.aiRequestUserMessage != nil {
            tabs.append(.aiRequest)
        }
        return tabs
    }

    private var hasAudioFile: Bool {
        if let urlString = transcription.audioFileURL,
           let url = URL(string: urlString),
           FileManager.default.fileExists(atPath: url.path) {
            return true
        }
        return false
    }

    private var copyTextForCurrentTab: String {
        switch selectedTab {
        case .original:
            return transcription.text
        case .enhanced:
            return transcription.enhancedText ?? transcription.text
        case .aiRequest:
            var result = ""
            if let systemMsg = transcription.aiRequestSystemMessage, !systemMsg.isEmpty {
                result += systemMsg
            }
            if let userMsg = transcription.aiRequestUserMessage, !userMsg.isEmpty {
                if !result.isEmpty {
                    result += "\n\n"
                }
                result += userMsg
            }
            return result.isEmpty ? transcription.text : result
        }
    }

    private var originalContentView: some View {
        Text(transcription.text)
            .font(.system(size: 15, weight: .regular, design: .default))
            .lineSpacing(2)
            .textSelection(.enabled)
    }

    private func enhancedContentView(_ enhancedText: String) -> some View {
        Text(enhancedText)
            .font(.system(size: 15, weight: .regular, design: .default))
            .lineSpacing(2)
            .textSelection(.enabled)
    }

    private var aiRequestContentView: some View {
        VStack(alignment: .leading, spacing: 12) {

            if let systemMsg = transcription.aiRequestSystemMessage, !systemMsg.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Transcription.systemPrompt.text)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(systemMsg)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .lineSpacing(2)
                        .textSelection(.enabled)
                }
            }

            if let userMsg = transcription.aiRequestUserMessage, !userMsg.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Transcription.userMessage.text)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(userMsg)
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .lineSpacing(2)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.accentColor.opacity(0.75) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .contentShape(.capsule)
                    )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggleSelection() }
            ))
            .toggleStyle(CircularCheckboxStyle())
            .labelsHidden()
            
            VStack(alignment: .leading, spacing: 12) {
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

                if isExpanded {
                    HStack(spacing: 4) {
                        ForEach(availableTabs, id: \.self) { tab in
                            TabButton(
                                title: tab.rawValue,
                                isSelected: selectedTab == tab,
                                action: { selectedTab = tab }
                            )
                        }

                        Spacer()

                        AnimatedCopyButton(textToCopy: copyTextForCurrentTab)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            switch selectedTab {
                            case .original:
                                originalContentView
                            case .enhanced:
                                if let enhancedText = transcription.enhancedText {
                                    enhancedContentView(enhancedText)
                                }
                            case .aiRequest:
                                aiRequestContentView
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 300)
                    .cornerRadius(8)

                    if hasAudioFile, let urlString = transcription.audioFileURL,
                       let url = URL(string: urlString) {
                        Divider()
                            .padding(.vertical, 8)
                        AudioPlayerView(url: url)
                    }

                    if hasMetadata {
                        Divider()
                            .padding(.vertical, 8)

                        VStack(alignment: .leading, spacing: 10) {
                            if let powerModeValue = powerModeDisplay(
                                name: transcription.powerModeName,
                                emoji: transcription.powerModeEmoji
                            ) {
                                metadataRow(
                                    icon: "bolt.fill",
                                    label: L10n.Transcription.powerMode.text,
                                    value: powerModeValue
                                )
                            }
                            metadataRow(icon: "hourglass", label: L10n.Transcription.audioDuration.text, value: formatTiming(transcription.duration))
                            if let modelName = transcription.transcriptionModelName {
                                metadataRow(icon: "cpu.fill", label: L10n.Transcription.transcriptionModel.text, value: modelName)
                            }
                            if let aiModel = transcription.aiEnhancementModelName {
                                metadataRow(icon: "sparkles", label: L10n.Transcription.enhancementModel.text, value: aiModel)
                            }
                            if let promptName = transcription.promptName {
                                metadataRow(icon: "text.bubble.fill", label: L10n.Transcription.promptUsed.text, value: promptName)
                            }
                            if let duration = transcription.transcriptionDuration {
                                metadataRow(icon: "clock.fill", label: L10n.Transcription.transcriptionTime.text, value: formatTiming(duration))
                            }
                            if let duration = transcription.enhancementDuration {
                                metadataRow(icon: "clock.fill", label: L10n.Transcription.enhancementTime.text, value: formatTiming(duration))
                            }
                        }
                    }
                } else {
                    Text(transcription.text)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .lineLimit(2)
                        .lineSpacing(2)
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
                    Label(L10n.Transcription.copyEnhanced.text, systemImage: "doc.on.doc")
                }
            }

            Button {
                let _ = ClipboardManager.copyToClipboard(transcription.text)
            } label: {
                Label(L10n.Transcription.copyOriginal.text, systemImage: "doc.on.doc")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(L10n.Common.delete.text, systemImage: "trash")
            }
        }
        .onChange(of: isExpanded) { oldValue, newValue in
            if newValue {
                selectedTab = transcription.enhancedText != nil ? .enhanced : .original
            }
        }
    }

    private var hasMetadata: Bool {
        transcription.powerModeName != nil ||
        transcription.powerModeEmoji != nil ||
        transcription.transcriptionModelName != nil ||
        transcription.aiEnhancementModelName != nil ||
        transcription.promptName != nil ||
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
    
    private func metadataRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
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

    private func powerModeDisplay(name: String?, emoji: String?) -> String? {
        guard name != nil || emoji != nil else { return nil }

        switch (emoji?.trimmingCharacters(in: .whitespacesAndNewlines), name?.trimmingCharacters(in: .whitespacesAndNewlines)) {
        case let (.some(emojiValue), .some(nameValue)) where !emojiValue.isEmpty && !nameValue.isEmpty:
            return "\(emojiValue) \(nameValue)"
        case let (.some(emojiValue), _) where !emojiValue.isEmpty:
            return emojiValue
        case let (_, .some(nameValue)) where !nameValue.isEmpty:
            return nameValue
        default:
            return nil
        }
    }
}
