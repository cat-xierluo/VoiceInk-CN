import SwiftUI
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
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No Transcriptions Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Start recording to see your metrics")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            MetricCard(
                title: "Words Captured",
                value: "\(totalWordsTranscribed)",
                icon: "text.word.spacing",
                color: .blue
            )
            MetricCard(
                title: "Voice-to-Text Sessions",
                value: "\(transcriptions.count)",
                icon: "mic.circle.fill",
                color: .green
            )
            MetricCard(
                title: "Average Words/Minute",
                value: String(format: "%.1f", averageWordsPerMinute),
                icon: "speedometer",
                color: .orange
            )
            MetricCard(
                title: "Words/Session",
                value: String(format: "%.1f", averageWordsPerSession),
                icon: "chart.bar.fill",
                color: .purple
            )
        }
    }
    
    private var voiceInkTrendChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("30-Day VoiceInk Trend")
                .font(.headline)
            
            Chart {
                ForEach(dailyTranscriptionCounts, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Sessions", item.count)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", item.date),
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
    private var averageWordsPerMinute: Double {
        guard totalRecordedTime > 0 else { return 0 }
        return Double(totalWordsTranscribed) / (totalRecordedTime / 60.0)
    }
    
    private var averageWordsPerSession: Double {
        guard !transcriptions.isEmpty else { return 0 }
        return Double(totalWordsTranscribed) / Double(transcriptions.count)
    }
} 
