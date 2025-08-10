import SwiftUI

struct TimeEfficiencyView: View {
    // MARK: - Properties
    
    private let totalRecordedTime: TimeInterval
    private let estimatedTypingTime: TimeInterval
    
    // Computed properties for efficiency metrics
    private var timeSaved: TimeInterval {
        estimatedTypingTime - totalRecordedTime
    }
    
    private var efficiencyMultiplier: Double {
        guard totalRecordedTime > 0 else { return 0 }
        let multiplier = estimatedTypingTime / totalRecordedTime
        return round(multiplier * 10) / 10  // Round to 1 decimal place
    }
    
    private var efficiencyMultiplierFormatted: String {
        String(format: "%.1fx", efficiencyMultiplier)
    }
    
    // MARK: - Initializer
    
    init(totalRecordedTime: TimeInterval, estimatedTypingTime: TimeInterval) {
        self.totalRecordedTime = totalRecordedTime
        self.estimatedTypingTime = estimatedTypingTime
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            mainContent
        }
    }
    
    // MARK: - Main Content View
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            headerSection
            timeComparisonSection
            bottomSection
        }
        .padding(.vertical, 24)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 8) {
                Text("You are")
                    .font(.system(size: 32, weight: .bold))
                
                Text("\(efficiencyMultiplierFormatted) Faster")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(efficiencyGradient)
                
                Text("with VoiceInk")
                    .font(.system(size: 32, weight: .bold))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 24)
    }
    
    private var timeComparisonSection: some View {
        HStack(spacing: 16) {
            TimeBlockView(
                duration: totalRecordedTime,
                label: "SPEAKING TIME",
                icon: "mic.circle.fill",
                color: .green
            )
            
            TimeBlockView(
                duration: estimatedTypingTime,
                label: "TYPING TIME",
                icon: "keyboard.fill",
                color: .orange
            )
        }
        .padding(.horizontal, 24)
    }
    
    private var bottomSection: some View {
        HStack {
            timeSavedView
            Spacer()
            reportIssueButton
        }
        .padding(.horizontal, 24)
    }
    
    private var timeSavedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TIME SAVED")
                .font(.system(size: 13, weight: .heavy))
                .tracking(4)
                .foregroundColor(.secondary)
            
            Text(formatDuration(timeSaved))
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(accentGradient)
        }
    }
    
    private var reportIssueButton: some View {
        Button(action: {
            EmailSupport.openSupportEmail()
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Left icon
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                
                // Center text
                Text("Feedback or Issues?")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                
                Spacer(minLength: 8)
                
                // Right button
                Text("Report")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.white))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(accentGradient)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .shadow(color: Color.accentColor.opacity(0.2), radius: 3, y: 1)
        .frame(maxWidth: 280)
    }
    
    private var efficiencyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.green,
                Color.green.opacity(0.7)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(nsColor: .controlAccentColor),
                Color(nsColor: .controlAccentColor).opacity(0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Utility Methods
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

// MARK: - Helper Struct

struct TimeBlockView: View {
    let duration: TimeInterval
    let label: String
    let icon: String
    let color: Color
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDuration(duration))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text(label)
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}
