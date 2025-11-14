import SwiftUI
import AppKit

// MARK: - Native Apple Model Card View
struct NativeAppleModelCardView: View {
    let model: NativeAppleModel
    let isCurrent: Bool
    var setDefaultAction: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Main Content
            VStack(alignment: .leading, spacing: 6) {
                headerSection
                metadataSection
                descriptionSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Controls
            actionSection
        }
        .padding(16)
        .background(CardBackground(isSelected: isCurrent, useAccentGradientWhenSelected: isCurrent))
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
            } else {
                Text(L10n.AIModels.builtIn.text)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
                    .foregroundColor(Color.blue)
            }
        }
    }
    
    private var metadataSection: some View {
        HStack(spacing: 12) {
            // Native Apple
            Label(L10n.AIModels.nativeApple.text, systemImage: "apple.logo")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // Language
            Label(localizedLanguageLabel, systemImage: "globe")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // On-Device
            Label(L10n.AIModels.onDevice.text, systemImage: "checkmark.shield")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // Requires macOS 26+
            Label(L10n.AIModels.macOSRequirement.format(26), systemImage: "macbook")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
        }
        .lineLimit(1)
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
            } else {
                Button(action: setDefaultAction) {
                    Text(L10n.AIModels.setAsDefault.text)
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
    
    private var localizedLanguageLabel: LocalizedStringKey {
        model.isMultilingualModel ? L10n.AIModels.languageMultilingualShort.text : L10n.AIModels.languageEnglishOnlyShort.text
    }
}
