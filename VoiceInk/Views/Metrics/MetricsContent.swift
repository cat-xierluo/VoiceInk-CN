import SwiftUI
<<<<<<< HEAD
import Charts

struct MetricsContent: View {
    let transcriptions: [Transcription]
    
    var body: some View {
        if transcriptions.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    TimeEfficiencyView(totalRecordedTime: totalRecordedTime, estimatedTypingTime: estimatedTypingTime)
                    
                    metricsGrid
                    
                    voiceInkTrendChart
                }
                .padding()
=======

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
                            HStack(alignment: .top, spacing: 18) {
                                HelpAndResourcesSection()
                                DashboardPromotionsSection(licenseState: licenseState)
                            }

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
>>>>>>> upstream/main
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform")
<<<<<<< HEAD
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(NSLocalizedString("No Transcriptions Yet", comment: "No Transcriptions Yet"))
                .font(.title2)
                .fontWeight(.semibold)
            Text(NSLocalizedString("Start recording to see your metrics", comment: "Start recording to see your metrics"))
=======
                .font(.system(size: 56, weight: .semibold))
                .foregroundColor(.secondary)
            Text("No Transcriptions Yet")
                .font(.title3.weight(.semibold))
            Text("Start your first recording to unlock value insights.")
>>>>>>> upstream/main
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
    
<<<<<<< HEAD
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            MetricCard(
                title: NSLocalizedString(NSLocalizedString("Words Captured", comment: "Words Captured"), comment: "Words Captured"),
                value: NSLocalizedString("\(totalWordsTranscribed)", comment: "\(totalWordsTranscribed)"),
                icon: "text.word.spacing",
                color: .blue
            )
            MetricCard(
                title: NSLocalizedString(NSLocalizedString("Voice-to-Text Sessions", comment: "Voice-to-Text Sessions"), comment: "Voice-to-Text Sessions"),
                value: "\(transcriptions.count)",
                icon: "mic.circle.fill",
                color: .green
            )
            MetricCard(
                title: NSLocalizedString(NSLocalizedString("Average Words/Minute", comment: "Average Words/Minute"), comment: "Average Words/Minute"),
                value: String(format: NSLocalizedString(NSLocalizedString("%.1f", comment: "%.1f"), comment: "%.1f"), averageWordsPerMinute),
                icon: NSLocalizedString("speedometer", comment: "speedometer"),
                color: .orange
            )
            MetricCard(
                title: NSLocalizedString(NSLocalizedString("Words/Session", comment: "Words/Session"), comment: "Words/Session"),
                value: String(format: "%.1f", averageWordsPerSession),
                icon: "chart.bar.fill",
                color: .purple
            )
        }
    }
    
    private var voiceInkTrendChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("30-Day VoiceInk Trend", comment: "30-Day VoiceInk Trend"))
                .font(.headline)
            
            Chart {
                ForEach(dailyTranscriptionCounts, id: \.date) { item in
                    LineMark(
x: .value(NSLocalizedString("Date", comment: "Date"), item.date),
                        y: .value("Sessions", item.count)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
x: .value(NSLocalizedString("Date", comment: "Date"), item.date),
                        y: .value("Sessions", item.count)
                    )
                    .foregroundStyle(LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 250)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // Computed properties for metrics
=======
    // MARK: - Sections
    
    private var heroSection: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer(minLength: 0)
                
                (Text("You have saved ")
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.85))
                 +
                 Text(formattedTimeSaved)
                    .fontWeight(.black)
                    .font(.system(size: 36, design: .rounded))
                    .foregroundStyle(.white)
                 +
                 Text(" with VoiceInk")
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.85))
                )
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
                title: "Sessions Recorded",
                value: "\(transcriptions.count)",
                detail: "VoiceInk sessions completed",
                color: .purple
            )
            
            MetricCard(
                icon: "text.alignleft",
                title: "Words Dictated",
                value: Formatters.formattedNumber(totalWordsTranscribed),
                detail: "words generated",
                color: Color(nsColor: .controlAccentColor)
            )
            
            MetricCard(
                icon: "speedometer",
                title: "Words Per Minute",
                value: averageWordsPerMinute > 0
                    ? String(format: "%.1f", averageWordsPerMinute)
                    : "–",
                detail: "VoiceInk vs. typing by hand",
                color: .yellow
            )
            
            MetricCard(
                icon: "keyboard.fill",
                title: "Keystrokes Saved",
                value: Formatters.formattedNumber(totalKeystrokesSaved),
                detail: "fewer keystrokes",
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
    
    private var formattedTimeSaved: String {
        let formatted = Formatters.formattedDuration(timeSaved, style: .full, fallback: "Time savings coming soon")
        return formatted
    }
    
    private var heroSubtitle: String {
        guard !transcriptions.isEmpty else {
            return "Your VoiceInk journey starts with your first recording."
        }
        
        let wordsText = Formatters.formattedNumber(totalWordsTranscribed)
        let sessionCount = transcriptions.count
        let sessionText = sessionCount == 1 ? "session" : "sessions"
        
        return "Dictated \(wordsText) words across \(sessionCount) \(sessionText)."
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
    
>>>>>>> upstream/main
    private var totalWordsTranscribed: Int {
        transcriptions.reduce(0) { $0 + $1.text.split(separator: " ").count }
    }
    
    private var totalRecordedTime: TimeInterval {
        transcriptions.reduce(0) { $0 + $1.duration }
    }
    
    private var estimatedTypingTime: TimeInterval {
        let averageTypingSpeed: Double = 35 // words per minute
        let totalWords = Double(totalWordsTranscribed)
        let estimatedTypingTimeInMinutes = totalWords / averageTypingSpeed
        return estimatedTypingTimeInMinutes * 60
    }
    
<<<<<<< HEAD
    private var dailyTranscriptionCounts: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -29, to: now)!
        
        let dailyData = (0..<30).compactMap { dayOffset -> (date: Date, count: Int)? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { return nil }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let count = transcriptions.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }.count
            return (date: startOfDay, count: count)
        }
        
        return dailyData.reversed()
    }
    
    // Add computed properties for new metrics
=======
    private var timeSaved: TimeInterval {
        max(estimatedTypingTime - totalRecordedTime, 0)
    }
    
>>>>>>> upstream/main
    private var averageWordsPerMinute: Double {
        guard totalRecordedTime > 0 else { return 0 }
        return Double(totalWordsTranscribed) / (totalRecordedTime / 60.0)
    }
    
<<<<<<< HEAD
    private var averageWordsPerSession: Double {
        guard !transcriptions.isEmpty else { return 0 }
        return Double(totalWordsTranscribed) / Double(transcriptions.count)
    }
} 
=======
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

                Text(isClicked ? "Sending" : "Feedback or Issues?")
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

                Text(isCopied ? "Copied!" : "Copy System Info")
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
>>>>>>> upstream/main
