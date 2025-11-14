import SwiftUI

struct MetricsContent: View {
    let transcriptions: [Transcription]
    let licenseState: LicenseViewModel.LicenseState
    
    var body: some View {
        Group {
            if transcriptions.isEmpty {
                emptyStateView
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 24) {
                            heroSection
                            metricsSection
                            HelpAndResourcesSection()

                            Spacer(minLength: 20)

                            HStack {
                                Spacer()
                                footerActionsView
                            }
                        }
                        .frame(minHeight: geometry.size.height - 56)
                        .padding(.vertical, 28)
                        .padding(.horizontal, 32)
                    }
                    .background(Color(.windowBackgroundColor))
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform")
                .font(.system(size: 56, weight: .semibold))
                .foregroundColor(.secondary)
            Text(L10n.Metrics.noTranscriptionsYet.string)
                .font(.title3.weight(.semibold))
            Text(L10n.Metrics.startFirstRecording.string)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
    
    // MARK: - Sections
    
    private var heroSection: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer(minLength: 0)
                
                heroTitle
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                
                Spacer(minLength: 0)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            
            Text(heroSubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(heroGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 30, x: 0, y: 16)
    }
    
    private var metricsSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)], spacing: 16) {
            MetricCard(
                icon: "mic.fill",
                title: L10n.Metrics.sessionsRecorded.string,
                value: "\(transcriptions.count)",
                detail: L10n.Metrics.sessionsCompleted.string,
                color: .purple
            )

            MetricCard(
                icon: "text.alignleft",
                title: L10n.Metrics.wordsDictated.string,
                value: Formatters.formattedNumber(totalWordsTranscribed),
                detail: L10n.Metrics.wordsGenerated.string,
                color: Color(nsColor: .controlAccentColor)
            )

            MetricCard(
                icon: "speedometer",
                title: L10n.Metrics.wordsPerMinute.string,
                value: averageWordsPerMinute > 0
                    ? String(format: "%.1f", averageWordsPerMinute)
                    : "–",
                detail: L10n.Metrics.vsTyping.string,
                color: .yellow
            )

            MetricCard(
                icon: "keyboard.fill",
                title: L10n.Metrics.keystrokesSaved.string,
                value: Formatters.formattedNumber(totalKeystrokesSaved),
                detail: L10n.Metrics.fewerKeystrokes.string,
                color: .orange
            )
        }
    }
    
    private var footerActionsView: some View {
        HStack(spacing: 12) {
            CopySystemInfoButton()
            FeedbackButton()
        }
    }
    
    @ViewBuilder
    private var heroTitle: some View {
        if transcriptions.isEmpty {
            Text(L10n.Metrics.timeSavingsComing.text)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
        } else {
            (Text(L10n.Metrics.savedWithVoiceInk.text)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.85))
             +
             Text(formattedTimeSaved)
                .fontWeight(.black)
                .font(.system(size: 36, design: .rounded))
                .foregroundStyle(.white)
             +
             Text(L10n.Metrics.withVoiceInk.text)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.85))
            )
        }
    }

    private var formattedTimeSaved: String {
        Formatters.formattedDuration(
            timeSaved,
            style: .full,
            fallback: L10n.Metrics.Performance.zeroSeconds.string
        )
    }

    private var heroSubtitle: String {
        guard !transcriptions.isEmpty else {
            return L10n.Metrics.journeyStarts.string
        }

        let wordsText = Formatters.formattedNumber(totalWordsTranscribed)
        let sessionCount = transcriptions.count
        let sessionText = sessionCount == 1 ? L10n.Metrics.sessionSingular.string : L10n.Metrics.sessionPlural.string

        return L10n.Metrics.dictatedFormat.format(wordsText, sessionCount, sessionText)
    }
    
    private var heroGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(nsColor: .controlAccentColor),
                Color(nsColor: .controlAccentColor).opacity(0.85),
                Color(nsColor: .controlAccentColor).opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Computed Metrics
    
    private var totalWordsTranscribed: Int {
        transcriptions.reduce(0) { $0 + wordCount(for: $1) }
    }
    
    private var timeSaved: TimeInterval {
        max(totalTypingTime - totalSpokenTime, 0)
    }
    
    private var averageWordsPerMinute: Double {
        guard totalSpokenTime > 0 else { return 0 }
        return Double(totalWordsTranscribed) / (totalSpokenTime / 60.0)
    }
    
    private var totalTypingTime: TimeInterval {
        transcriptions.reduce(0) { $0 + typingTime(forWordCount: wordCount(for: $1)) }
    }
    
    private var totalSpokenTime: TimeInterval {
        transcriptions.reduce(0) { $0 + spokenTime(for: $1, fallbackWords: wordCount(for: $1)) }
    }
    
    private func wordCount(for transcription: Transcription) -> Int {
        transcription.text.split { $0.isWhitespace }.count
    }
    
    private func typingTime(forWordCount count: Int) -> TimeInterval {
        let averageTypingSpeed: Double = 35 // words per minute
        let minutes = Double(count) / averageTypingSpeed
        return minutes * 60
    }
    
    private func spokenTime(for transcription: Transcription, fallbackWords count: Int) -> TimeInterval {
        let estimatedSpeech = estimatedSpeechTime(forWordCount: count)
        let recorded = transcription.duration
        guard recorded > 0 else { return estimatedSpeech }
        return min(recorded, estimatedSpeech)
    }
    
    private func estimatedSpeechTime(forWordCount count: Int) -> TimeInterval {
        let averageSpeakingSpeed: Double = 120 // words per minute
        let minutes = Double(count) / averageSpeakingSpeed
        return minutes * 60
    }
    
    private var totalKeystrokesSaved: Int {
        Int(Double(totalWordsTranscribed) * 5.0)
    }
    
    private var firstTranscriptionDateText: String? {
        guard let firstDate = transcriptions.map(\.timestamp).min() else { return nil }
        return dateFormatter.string(from: firstDate)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

private enum Formatters {
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        return formatter
    }()
    
    static func formattedNumber(_ value: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    static func formattedDuration(_ interval: TimeInterval, style: DateComponentsFormatter.UnitsStyle, fallback: String = "–") -> String {
        guard interval > 0 else { return fallback }
        durationFormatter.unitsStyle = style
        durationFormatter.allowedUnits = interval >= 3600 ? [.hour, .minute] : [.minute, .second]
        return durationFormatter.string(from: interval) ?? fallback
    }
}

private struct FeedbackButton: View {
    @State private var isClicked: Bool = false

    var body: some View {
        Button(action: {
            openFeedback()
        }) {
            HStack(spacing: 8) {
                Image(systemName: isClicked ? "checkmark.circle.fill" : "exclamationmark.bubble.fill")
                    .rotationEffect(.degrees(isClicked ? 360 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isClicked)

                Text(isClicked ? L10n.Metrics.sending.string : L10n.Metrics.feedbackOrIssues.string)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isClicked)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(.thinMaterial))
        }
        .buttonStyle(.plain)
        .scaleEffect(isClicked ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isClicked)
    }

    private func openFeedback() {
        EmailSupport.openSupportEmail()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isClicked = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isClicked = false
            }
        }
    }
}

private struct CopySystemInfoButton: View {
    @State private var isCopied: Bool = false

    var body: some View {
        Button(action: {
            copySystemInfo()
        }) {
            HStack(spacing: 8) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .rotationEffect(.degrees(isCopied ? 360 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)

                Text(isCopied ? L10n.Metrics.copied.string : L10n.Metrics.copySystemInfo.string)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(.thinMaterial))
        }
        .buttonStyle(.plain)
        .scaleEffect(isCopied ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCopied)
    }

    private func copySystemInfo() {
        SystemInfoService.shared.copySystemInfoToClipboard()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isCopied = false
            }
        }
    }
}
