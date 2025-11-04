import SwiftUI

/// A view that provides a fallback UI to display transcribed text when it cannot be pasted automatically.
struct TranscriptionFallbackView: View {
    let transcriptionText: String
    let onCopy: () -> Void
    let onClose: () -> Void
    let onTextChange: ((String) -> Void)?
    
    @State private var editableText: String = ""
    @State private var isHoveringTitleBar = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Bar
            HStack {
                Spacer().frame(width: 20, height: 20)
                
                Spacer()
                
                Text("VoiceInk")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isHoveringTitleBar {
                    Button(action: {
                        ClipboardManager.copyToClipboard(editableText)
                        onCopy()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .buttonStyle(TitleBarButtonStyle(color: .blue))
                } else {
                    Spacer().frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHoveringTitleBar = hovering
                }
            }
            
            // Text Editor
            TextEditor(text: $editableText)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 16)
                .onAppear {
                    editableText = transcriptionText
                }
                .onChange(of: editableText) { newValue in
                    onTextChange?(newValue)
                }
        }
        .background(.regularMaterial)
        .cornerRadius(16)
        .background(
            Button("", action: onClose)
                .keyboardShortcut("w", modifiers: .command)
                .hidden()
        )
    }
}

private struct TitleBarButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(3)
            .background(Circle().fill(color))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

#Preview {
    VStack {
        TranscriptionFallbackView(
            transcriptionText: "Short text.",
            onCopy: {},
            onClose: {},
            onTextChange: nil
        )
        TranscriptionFallbackView(
            transcriptionText: "This is a much longer piece of transcription text to demonstrate how the view will adaptively resize to accommodate more content while still respecting the maximum constraints.",
            onCopy: {},
            onClose: {},
            onTextChange: nil
        )
    }
    .padding()
}
