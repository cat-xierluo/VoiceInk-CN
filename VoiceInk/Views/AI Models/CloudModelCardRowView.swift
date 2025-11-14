import SwiftUI
import AppKit

// MARK: - Cloud Model Card View
struct CloudModelCardView: View {
    let model: CloudModel
    let isCurrent: Bool
    var setDefaultAction: () -> Void
    
    @EnvironmentObject private var whisperState: WhisperState
    @StateObject private var aiService = AIService()
    @State private var isExpanded = false
    @State private var apiKey = ""
    @State private var isVerifying = false
    @State private var verificationStatus: VerificationStatus = .none
    @State private var isConfiguredState: Bool = false
    
    enum VerificationStatus {
        case none, verifying, success, failure
    }
    
    private var isConfigured: Bool {
        guard let savedKey = UserDefaults.standard.string(forKey: "\(providerKey)APIKey") else {
            return false
        }
        return !savedKey.isEmpty
    }
    
    private var providerKey: String {
        switch model.provider {
        case .groq:
            return "GROQ"
        case .elevenLabs:
            return "ElevenLabs"
        case .deepgram:
            return "Deepgram"
        case .mistral:
            return "Mistral"
        case .gemini:
            return "Gemini"
        case .soniox:
            return "Soniox"
        default:
            return model.provider.rawValue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    headerSection
                    metadataSection
                    descriptionSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                actionSection
            }
            .padding(16)
            
            // Expandable configuration section
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                
                configurationSection
                    .padding(16)
            }
        }
        .background(CardBackground(isSelected: isCurrent, useAccentGradientWhenSelected: isCurrent))
        .onAppear {
            loadSavedAPIKey()
            isConfiguredState = isConfigured
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(model.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.labelColor))
            
            statusBadge
            
            Spacer()
        }
    }
    
    private var statusBadge: some View {
        Group {
            if isCurrent {
                Text(L10n.AIModels.defaultModel.text)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.accentColor))
                    .foregroundColor(.white)
            } else if isConfiguredState {
                Text(L10n.AIModels.configured.text)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.systemGreen).opacity(0.2)))
                    .foregroundColor(Color(.systemGreen))
            } else {
                Text(L10n.AIModels.setupRequired.text)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.systemOrange).opacity(0.2)))
                    .foregroundColor(Color(.systemOrange))
            }
        }
    }
    
    private var metadataSection: some View {
        HStack(spacing: 12) {
            // Provider
            Label(model.provider.localizedName, systemImage: "cloud")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // Language
            Label(localizedLanguageLabel, systemImage: "globe")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            Label(L10n.AIModels.cloudModel.text, systemImage: "icloud")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // Accuracy
            HStack(spacing: 3) {
                Text(L10n.AIModels.accuracy.text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(.secondaryLabelColor))
                progressDotsWithNumber(value: model.accuracy * 10)
            }
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
        }
        .lineLimit(1)
    }
    
    private var localizedLanguageLabel: LocalizedStringKey {
        model.isMultilingualModel ? L10n.AIModels.languageMultilingualShort.text : L10n.AIModels.languageEnglishOnlyShort.text
    }
    
    private var descriptionSection: some View {
        Text(model.description)
            .font(.system(size: 11))
            .foregroundColor(Color(.secondaryLabelColor))
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
    }
    
    private var actionSection: some View {
        HStack(spacing: 8) {
            if isCurrent {
                Text(L10n.AIModels.defaultModel.text)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabelColor))
            } else if isConfiguredState {
                Button(action: setDefaultAction) {
                    Text(L10n.AIModels.setAsDefault.text)
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Button(action: {
                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 20)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(L10n.AIModels.configure.text)
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "gear")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.controlAccentColor))
                            .shadow(color: Color(.controlAccentColor).opacity(0.2), radius: 2, x: 0, y: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            if isConfiguredState {
                Menu {
                    Button {
                        clearAPIKey()
                    } label: {
                        Label(L10n.AIModels.removeApiKey.text, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20, height: 20)
            }
        }
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.AIModels.apiKeyConfig.text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.labelColor))
            
            HStack(spacing: 8) {
                SecureField(
                    L10n.AIModels.enterProviderApiKey.format(model.provider.localizedName),
                    text: $apiKey
                )
                    .textFieldStyle(.roundedBorder)
                    .disabled(isVerifying)
                
                Button(action: verifyAPIKey) {
                    HStack(spacing: 4) {
                        if isVerifying {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: verificationStatus == .success ? "checkmark" : "checkmark.shield")
                                .font(.system(size: 12, weight: .medium))
                        }
                        Text(isVerifying ? L10n.AIModels.verifying.text : L10n.AIModels.verify.text)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(verificationStatus == .success ? Color(.systemGreen) : Color(.controlAccentColor))
                    )
                }
                .buttonStyle(.plain)
                .disabled(apiKey.isEmpty || isVerifying)
            }
            
            if verificationStatus == .failure {
                Text(L10n.AIModels.invalidAPIKey.text)
                    .font(.caption)
                    .foregroundColor(Color(.systemRed))
            } else if verificationStatus == .success {
                Text(L10n.AIModels.apiKeyVerified.text)
                    .font(.caption)
                    .foregroundColor(Color(.systemGreen))
            }
        }
    }
    
    private func loadSavedAPIKey() {
        if let savedKey = UserDefaults.standard.string(forKey: "\(providerKey)APIKey") {
            apiKey = savedKey
            verificationStatus = .success
        }
    }
    
    private func verifyAPIKey() {
        guard !apiKey.isEmpty else { return }
        
        isVerifying = true
        verificationStatus = .verifying
        
        switch model.provider {
        case .groq:
            aiService.selectedProvider = .groq
        case .elevenLabs:
            aiService.selectedProvider = .elevenLabs
        case .deepgram:
            aiService.selectedProvider = .deepgram
        case .mistral:
            aiService.selectedProvider = .mistral
        case .gemini:
            aiService.selectedProvider = .gemini
        case .soniox:
            aiService.selectedProvider = .soniox
        default:
            // This case should ideally not be hit for cloud models in this view
            print("Warning: verifyAPIKey called for unsupported provider \(model.provider.rawValue)")
            isVerifying = false
            verificationStatus = .failure
            return
        }
        
        aiService.saveAPIKey(apiKey) { isValid in
            DispatchQueue.main.async {
                self.isVerifying = false
                if isValid {
                    self.verificationStatus = .success
                    // Save the API key
                    UserDefaults.standard.set(self.apiKey, forKey: "\(self.providerKey)APIKey")
                    self.isConfiguredState = true
                    
                    // Collapse the configuration section after successful verification
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isExpanded = false
                    }
                } else {
                    self.verificationStatus = .failure
                }
                
                // Restore original provider
                // aiService.selectedProvider = originalProvider // This line was removed as per the new_code
            }
        }
    }
    
    private func clearAPIKey() {
        UserDefaults.standard.removeObject(forKey: "\(providerKey)APIKey")
        apiKey = ""
        verificationStatus = .none
        isConfiguredState = false
        
        // If this model is currently the default, clear it
        if isCurrent {
            Task {
                await MainActor.run {
                    whisperState.currentTranscriptionModel = nil
                    UserDefaults.standard.removeObject(forKey: "CurrentTranscriptionModel")
                }
            }
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isExpanded = false
        }
    }
}
