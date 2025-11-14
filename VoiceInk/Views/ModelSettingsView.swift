import SwiftUI

struct ModelSettingsView: View {
    @ObservedObject var whisperPrompt: WhisperPrompt
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("IsTextFormattingEnabled") private var isTextFormattingEnabled = true
    @AppStorage("IsVADEnabled") private var isVADEnabled = true
    @AppStorage("AppendTrailingSpace") private var appendTrailingSpace = true
    @State private var customPrompt: String = ""
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.SettingsExtended.ModelSettings.outputFormat.text)
                    .font(.headline)
                
                InfoTip(
                    title: L10n.SettingsExtended.ModelSettings.outputFormatGuideTitle.string,
                    message: L10n.SettingsExtended.ModelSettings.outputFormatGuideMessage.string,
                    learnMoreURL: "https://cookbook.openai.com/examples/whisper_prompting_guide#comparison-with-gpt-prompting"
                )
                
                Spacer()
                
                Button(action: {
                    if isEditing {
                        // Save changes
                        whisperPrompt.setCustomPrompt(customPrompt, for: selectedLanguage)
                        isEditing = false
                    } else {
                        // Enter edit mode
                        customPrompt = whisperPrompt.getLanguagePrompt(for: selectedLanguage)
                        isEditing = true
                    }
                }) {
                    Text(isEditing ? L10n.Common.save.text : L10n.Common.edit.text)
                        .font(.caption)
                }
            }
            
            if isEditing {
                TextEditor(text: $customPrompt)
                    .font(.system(size: 12))
                    .padding(8)
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                
            } else {
                Text(whisperPrompt.getLanguagePrompt(for: selectedLanguage))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.windowBackgroundColor).opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }

            Divider().padding(.vertical, 4)

            HStack {
                Toggle(isOn: $appendTrailingSpace) {
                    Text(L10n.SettingsExtended.ModelSettings.addSpaceAfterPaste.text)
                }
                .toggleStyle(.switch)
                
                InfoTip(
                    title: L10n.SettingsExtended.ModelSettings.trailingSpaceTitle.string,
                    message: L10n.SettingsExtended.ModelSettings.trailingSpaceMessage.string
                )
            }

            HStack {
                Toggle(isOn: $isTextFormattingEnabled) {
                    Text(L10n.SettingsExtended.ModelSettings.automaticTextFormatting.text)
                }
                .toggleStyle(.switch)
                
                InfoTip(
                    title: L10n.SettingsExtended.ModelSettings.textFormattingTitle.string,
                    message: L10n.SettingsExtended.ModelSettings.textFormattingMessage.string
                )
            }

            HStack {
                Toggle(isOn: $isVADEnabled) {
                    Text(L10n.SettingsExtended.ModelSettings.voiceActivityDetection.text)
                }
                .toggleStyle(.switch)
                
                InfoTip(
                    title: L10n.SettingsExtended.ModelSettings.vadTitle.string,
                    message: L10n.SettingsExtended.ModelSettings.vadMessage.string
                )
            }

        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        // Reset the editor when language changes
        .onChange(of: selectedLanguage) { oldValue, newValue in
            if isEditing {
                customPrompt = whisperPrompt.getLanguagePrompt(for: selectedLanguage)
            }
        }
    }
} 
