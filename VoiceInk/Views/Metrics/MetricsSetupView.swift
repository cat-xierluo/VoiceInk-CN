import SwiftUI
import KeyboardShortcuts

struct MetricsSetupView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @State private var isAccessibilityEnabled = AXIsProcessTrusted()
    @State private var isScreenRecordingEnabled = CGPreflightScreenCaptureAccess()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    AppIconView()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 20)
                       
                    VStack(spacing: 4) {
                        Text(L10n.Metrics.welcomeToVoiceInk.string)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text(L10n.Metrics.completeSetup.string)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Setup Steps
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<4) { index in
                        setupStep(for: index)
                        if index < 3 {
                            Divider().padding(.leading, 70)
                        }
                    }
                }
                .background(Color(NSColor.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Action Button
                actionButton
                    .frame(maxWidth: 400)
                
                // Help Text
                helpText
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 600)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func setupStep(for index: Int) -> some View {
        let stepInfo = stepDetails(for: index)
        return HStack(spacing: 16) {
            Image(systemName: stepInfo.icon)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background((stepInfo.isCompleted ? Color.green : Color.accentColor).opacity(0.1))
                .foregroundColor(stepInfo.isCompleted ? .green : Color.accentColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(stepInfo.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(stepInfo.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if stepInfo.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(NSColor.separatorColor))
            }
        }
        .padding()
    }
    
    private var actionButton: some View {
        Button(action: handleActionButton) {
            HStack {
                Text(getActionButtonTitle())
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
    }
    
    private func handleActionButton() {
        if isShortcutAndAccessibilityGranted {
            openModelManagement()
        } else {
            // Handle different permission requests based on which one is missing
            if hotkeyManager.selectedHotkey1 == .none {
                openSettings()
            } else if !AXIsProcessTrusted() {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            } else if !CGPreflightScreenCaptureAccess() {
                CGRequestScreenCaptureAccess()
                // After requesting, open system preferences as fallback
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    private func getActionButtonTitle() -> String {
        if hotkeyManager.selectedHotkey1 == .none {
            return L10n.Metrics.Setup.configureShortcut.string
        } else if !AXIsProcessTrusted() {
            return L10n.Metrics.Setup.enableAccessibilityAction.string
        } else if !CGPreflightScreenCaptureAccess() {
            return L10n.Metrics.Setup.enableScreenRecordingAction.string
        } else if whisperState.currentTranscriptionModel == nil {
            return L10n.Metrics.Setup.downloadModelAction.string
        }
        return L10n.Metrics.Setup.getStarted.string
    }
    
    private var helpText: some View {
        Text(L10n.Metrics.needHelp.string)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var isShortcutAndAccessibilityGranted: Bool {
        hotkeyManager.selectedHotkey1 != .none &&
        AXIsProcessTrusted() && 
        CGPreflightScreenCaptureAccess()
    }
    
    private func openSettings() {
        NotificationCenter.default.post(
            name: .navigateToDestination,
            object: nil,
            userInfo: ["destination": "Settings"]
        )
    }
    
    private func openModelManagement() {
        NotificationCenter.default.post(
            name: .navigateToDestination,
            object: nil,
            userInfo: ["destination": "AI Models"]
        )
    }
}

extension MetricsSetupView {
    private func stepDetails(for index: Int) -> (isCompleted: Bool, icon: String, title: LocalizedStringKey, description: LocalizedStringKey) {
        switch index {
        case 0:
            return (
                hotkeyManager.selectedHotkey1 != .none,
                "command",
                L10n.Metrics.Setup.setShortcutTitle.text,
                L10n.Metrics.Setup.setShortcutDescription.text
            )
        case 1:
            return (
                isAccessibilityEnabled,
                "hand.raised.fill",
                L10n.Metrics.Setup.accessibilityTitle.text,
                L10n.Metrics.Setup.accessibilityDescription.text
            )
        case 2:
            return (
                isScreenRecordingEnabled,
                "video.fill",
                L10n.Metrics.Setup.screenRecordingTitle.text,
                L10n.Metrics.Setup.screenRecordingDescription.text
            )
        default:
            return (
                whisperState.currentTranscriptionModel != nil,
                "arrow.down.to.line",
                L10n.Metrics.Setup.downloadModelTitle.text,
                L10n.Metrics.Setup.downloadModelDescription.text
            )
        }
    }
}
