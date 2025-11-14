import SwiftUI

// Define a display mode for flexible usage
enum LanguageDisplayMode {
    case full // For settings page with descriptions
    case menuItem // For menu bar with compact layout
}

struct LanguageSelectionView: View {
    @ObservedObject var whisperState: WhisperState
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    // Add display mode parameter with full as the default
    var displayMode: LanguageDisplayMode = .full
    @ObservedObject var whisperPrompt: WhisperPrompt

    private func updateLanguage(_ language: String) {
        // Update UI state - the UserDefaults updating is now automatic with @AppStorage
        selectedLanguage = language

        // Force the prompt to update for the new language
        whisperPrompt.updateTranscriptionPrompt()

        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
        NotificationCenter.default.post(name: .AppSettingsDidChange, object: nil)
    }
    
    // Function to check if current model is multilingual
    private func isMultilingualModel() -> Bool {
        guard let currentModel = whisperState.currentTranscriptionModel else {
            return false
        }
        return currentModel.isMultilingualModel
    }

    private func languageSelectionDisabled() -> Bool {
        guard let provider = whisperState.currentTranscriptionModel?.provider else {
            return false
        }
        return provider == .parakeet || provider == .gemini
    }

    // Function to get current model's supported languages
    private func getCurrentModelLanguages() -> [String: String] {
        guard let currentModel = whisperState.currentTranscriptionModel else {
            let english = NSLocalizedString(
                "English",
                tableName: nil,
                bundle: .main,
                value: "English",
                comment: "Default language name when no model is selected"
            )
            return ["en": english] // Default to English if no model found
        }
        return currentModel.supportedLanguages
    }

    // Get the display name of the current language
    private func currentLanguageDisplayName() -> String {
        let fallback = NSLocalizedString(
            "Unknown",
            tableName: nil,
            bundle: .main,
            value: "Unknown",
            comment: "Fallback label for unknown language"
        )
        return getCurrentModelLanguages()[selectedLanguage] ?? fallback
    }

    var body: some View {
        switch displayMode {
        case .full:
            fullView
        case .menuItem:
            menuItemView
        }
    }

    // The original full view layout for settings page
    private var fullView: some View {
        VStack(alignment: .leading, spacing: 16) {
            languageSelectionSection
        }
    }
    
    private var languageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.AIModels.transcriptionLanguage.text)
                .font(.headline)

            if let currentModel = whisperState.currentTranscriptionModel
            {
                if languageSelectionDisabled() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.AIModels.languageAutodetected.text)
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Text(String(format: L10n.AIModels.currentModel.string, currentModel.displayName))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(L10n.AIModels.languageAutodetectHelp.text)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)
                } else if isMultilingualModel() {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker(L10n.AIModels.selectLanguage.text, selection: $selectedLanguage) {
                            ForEach(
                                currentModel.supportedLanguages.sorted(by: {
                                    if $0.key == "auto" { return true }
                                    if $1.key == "auto" { return false }
                                    return $0.value < $1.value
                                }), id: \.key
                            ) { key, value in
                                Text(value).tag(key)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            updateLanguage(newValue)
                        }

                        Text(String(format: L10n.AIModels.currentModel.string, currentModel.displayName))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(L10n.AIModels.multilingualModelSupport.text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                } else {
                    // For English-only models, force set language to English
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.AIModels.languageEnglish.text)
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Text(String(format: L10n.AIModels.currentModel.string, currentModel.displayName))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(L10n.AIModels.englishOnlyModelSupport.text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .onAppear {
                        // Ensure English is set when viewing English-only model
                        updateLanguage("en")
                    }
                }
            } else {
                Text(L10n.AIModels.noModelSelected.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }

    // New compact view for menu bar
    private var menuItemView: some View {
        Group {
            if languageSelectionDisabled() {
                Button {
                    // Do nothing, just showing info
                } label: {
                    Text(L10n.AIModels.languageAutodetected.text)
                        .foregroundColor(.secondary)
                }
                .disabled(true)
            } else if isMultilingualModel() {
                Menu {
                    ForEach(
                        getCurrentModelLanguages().sorted(by: {
                            if $0.key == "auto" { return true }
                            if $1.key == "auto" { return false }
                            return $0.value < $1.value
                        }), id: \.key
                    ) { key, value in
                        Button {
                            updateLanguage(key)
                        } label: {
                            HStack {
                                Text(value)
                                if selectedLanguage == key {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(String(format: L10n.AIModels.languageMenuLabel.string, currentLanguageDisplayName()))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10))
                    }
                }
            } else {
                // For English-only models
                Button {
                    // Do nothing, just showing info
                } label: {
                    Text(L10n.AIModels.languageEnglishOnly.text)
                        .foregroundColor(.secondary)
                }
                .disabled(true)
                .onAppear {
                    // Ensure English is set for English-only models
                    updateLanguage("en")
                }
            }
        }
    }
}
