import SwiftUI
import KeyboardShortcuts

struct EnhancementShortcutsView: View {
    @ObservedObject private var shortcutSettings = EnhancementShortcutSettings.shared

    var body: some View {
        VStack(spacing: 12) {
            ShortcutRow(
                title: L10n.SettingsExtended.EnhancementShortcuts.toggleTitle.string,
                description: L10n.SettingsExtended.EnhancementShortcuts.toggleDescription.string,
                keyDisplay: ["⌘", "E"],
                isOn: $shortcutSettings.isToggleEnhancementShortcutEnabled
            )
            ShortcutRow(
                title: L10n.SettingsExtended.EnhancementShortcuts.switchTitle.string,
                description: L10n.SettingsExtended.EnhancementShortcuts.switchDescription.string,
                keyDisplay: ["⌘", "1 – 0"]
            )
        }
        .background(Color.clear)
    }
}

struct EnhancementShortcutsSection: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "command")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.SettingsExtended.EnhancementShortcuts.title.text)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(L10n.SettingsExtended.EnhancementShortcuts.description.text)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                    .transition(.opacity)
                
                VStack(alignment: .leading, spacing: 16) {
                    EnhancementShortcutsView()

                    Text(L10n.SettingsExtended.EnhancementShortcuts.availabilityNote.text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                        removal: .opacity
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CardBackground(isSelected: false))
    }
}

// MARK: - Supporting Views
private struct ShortcutRow: View {
    let title: String
    let description: String
    let keyDisplay: [String]
    private var isOn: Binding<Bool>?

    init(title: String, description: String, keyDisplay: [String], isOn: Binding<Bool>? = nil) {
        self.title = title
        self.description = description
        self.keyDisplay = keyDisplay
        self.isOn = isOn
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    InfoTip(title: title, message: description, learnMoreURL: "https://tryvoiceink.com/docs/switching-enhancement-prompts")
                }
            }
            
            Spacer(minLength: 0)
            
            if let isOn = isOn {
                keyDisplayView(isActive: isOn.wrappedValue)
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            isOn.wrappedValue.toggle()
                        }
                    }
                    .contentShape(Rectangle())
            } else {
                keyDisplayView()
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func keyDisplayView(isActive: Bool? = nil) -> some View {
        HStack(spacing: 8) {
            ForEach(keyDisplay, id: \.self) { key in
                KeyChip(label: key, isActive: isActive)
            }
        }
    }
}

private struct KeyChip: View {
    let label: String
    var isActive: Bool? = nil

    var body: some View {
        let active = isActive ?? true
        
        Text(label)
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(NSColor.separatorColor).opacity(active ? 0.7 : 0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(active ? .primary : .secondary)
            .shadow(color: Color(NSColor.shadowColor).opacity(active ? 0.1 : 0), radius: 4, x: 0, y: 2)
            .opacity(active ? 1.0 : 0.6)
    }
}
