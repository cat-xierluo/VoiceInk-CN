import SwiftUI

struct ModelSettingsView: View {
    @ObservedObject var whisperPrompt: WhisperPrompt
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("IsTextFormattingEnabled") private var isTextFormattingEnabled = true
    @AppStorage("IsVADEnabled") private var isVADEnabled = true
<<<<<<< HEAD
=======
    @AppStorage("AppendTrailingSpace") private var appendTrailingSpace = true
>>>>>>> upstream/main
    @State private var customPrompt: String = ""
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
<<<<<<< HEAD
Text(NSLocalizedString("Output Format", comment: "Output Format"))
                    .font(.headline)
                
                InfoTip(
title: NSLocalizedString("Output Format Guide", comment: "Output Format Guide"),
                    message: NSLocalizedString(NSLocalizedString("Unlike GPT, Voice Models(whisper) follows the style of your prompt rather than instructions. Use examples of your desired output format instead of commands.", comment: "Unlike GPT, Voice Models(whisper) follows the style of your prompt rather than instructions. Use examples of your desired output format instead of commands."), comment: "Unlike GPT, Voice Models(whisper) follows the style of your prompt rather than instructions. Use examples of your desired output format instead of commands."),
=======
                Text("Output Format")
                    .font(.headline)
                
                InfoTip(
                    title: "Output Format Guide",
                    message: "Unlike GPT, Voice Models(whisper) follows the style of your prompt rather than instructions. Use examples of your desired output format instead of commands.",
>>>>>>> upstream/main
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
<<<<<<< HEAD
                Text(isEditing ? NSLocalizedString("Save", comment: "Save") : NSLocalizedString("Edit", comment: "Edit"))
=======
                    Text(isEditing ? "Save" : "Edit")
>>>>>>> upstream/main
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
<<<<<<< HEAD
                Toggle(isOn: $isTextFormattingEnabled) {
Text(NSLocalizedString("Automatic text formatting", comment: "Automatic text formatting"))
=======
                Toggle(isOn: $appendTrailingSpace) {
                    Text("Add space after paste")
>>>>>>> upstream/main
                }
                .toggleStyle(.switch)
                
                InfoTip(
<<<<<<< HEAD
title: NSLocalizedString("Automatic Text Formatting", comment: "Automatic Text Formatting"),
                    message: NSLocalizedString("Apply intelligent text formatting to break large block of text into paragraphs.", comment: "Apply intelligent text formatting to break large block of text into paragraphs.")
=======
                    title: "Trailing Space",
                    message: "Automatically add a space after pasted text. Useful for space-delimited languages."
                )
            }

            HStack {
                Toggle(isOn: $isTextFormattingEnabled) {
                    Text("Automatic text formatting")
                }
                .toggleStyle(.switch)
                
                InfoTip(
                    title: "Automatic Text Formatting",
                    message: "Apply intelligent text formatting to break large block of text into paragraphs."
>>>>>>> upstream/main
                )
            }

            HStack {
                Toggle(isOn: $isVADEnabled) {
<<<<<<< HEAD
Text(NSLocalizedString("Voice Activity Detection (VAD)", comment: "Voice Activity Detection (VAD)"))
=======
                    Text("Voice Activity Detection (VAD)")
>>>>>>> upstream/main
                }
                .toggleStyle(.switch)
                
                InfoTip(
<<<<<<< HEAD
title: NSLocalizedString("Voice Activity Detection", comment: "Voice Activity Detection"),
                    message: NSLocalizedString("Detects speech segments and filters out silence to reduce hallucinations in local Whisper models.", comment: "Detects speech segments and filters out silence to reduce hallucinations in local Whisper models.")
=======
                    title: "Voice Activity Detection",
                    message: "Detect speech segments and filter out silence to improve accuracy of local models."
>>>>>>> upstream/main
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
