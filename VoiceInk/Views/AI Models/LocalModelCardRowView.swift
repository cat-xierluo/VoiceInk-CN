import SwiftUI
import AppKit
// MARK: - Local Model Card View
struct LocalModelCardView: View {
    let model: LocalModel
    let isDownloaded: Bool
    let isCurrent: Bool
    let downloadProgress: [String: Double]
    let modelURL: URL?
    let isWarming: Bool
    
    // Actions
    var deleteAction: () -> Void
    var setDefaultAction: () -> Void
    var downloadAction: () -> Void
    private var isDownloading: Bool {
        downloadProgress.keys.contains(model.name + "_main") || 
        downloadProgress.keys.contains(model.name + "_coreml")
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Main Content
            VStack(alignment: .leading, spacing: 6) {
                headerSection
                metadataSection
                descriptionSection
                progressSection
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
            } else if isDownloaded {
                Text(L10n.AIModels.downloaded.text)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.quaternaryLabelColor)))
                    .foregroundColor(Color(.labelColor))
            }
        }
    }
    
    private var metadataSection: some View {
        HStack(spacing: 12) {
            // Language
            Label(localizedLanguageLabel, systemImage: "globe")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // Size
            Label(model.size, systemImage: "internaldrive")
                .font(.system(size: 11))
                .foregroundColor(Color(.secondaryLabelColor))
                .lineLimit(1)
            
            // Speed
            HStack(spacing: 3) {
                Text(L10n.AIModels.speed.text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(.secondaryLabelColor))
                progressDotsWithNumber(value: model.speed * 10)
            }
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            
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
    
    private var progressSection: some View {
        Group {
            if isDownloading {
                DownloadProgressView(
                    modelName: model.name,
                    downloadProgress: downloadProgress
                )
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var actionSection: some View {
        HStack(spacing: 8) {
            if isCurrent {
                Text(L10n.AIModels.defaultModel.text)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabelColor))
            } else if isDownloaded {
                if isWarming {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text(L10n.AIModels.optimizingModel.text)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabelColor))
                    }
                } else {
                    Button(action: setDefaultAction) {
                        Text(L10n.AIModels.setAsDefault.text)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            } else {
                Button(action: downloadAction) {
                    HStack(spacing: 4) {
                        Text(isDownloading ? L10n.AIModels.downloading.text : L10n.AIModels.download.text)
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "arrow.down.circle")
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
                .disabled(isDownloading)
            }
            
            if isDownloaded {
                Menu {
                    Button(action: deleteAction) {
                        Label(L10n.AIModels.deleteModel.text, systemImage: "trash")
                    }
                    
                    Button {
                        if let modelURL = modelURL {
                            NSWorkspace.shared.selectFile(modelURL.path, inFileViewerRootedAtPath: "")
                        }
                    } label: {
                        Label(L10n.AIModels.showInFinder.text, systemImage: "folder")
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
}

// MARK: - Imported Local Model (minimal UI)
struct ImportedLocalModelCardView: View {
    let model: ImportedLocalModel
    let isDownloaded: Bool
    let isCurrent: Bool
    let modelURL: URL?

    var deleteAction: () -> Void
    var setDefaultAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.labelColor))
                    if isCurrent {
                        Text(L10n.AIModels.defaultModel.text)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
                    } else if isDownloaded {
                        Text(L10n.AIModels.imported.text)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color(.quaternaryLabelColor)))
                            .foregroundColor(Color(.labelColor))
                    }
                    Spacer()
                }

                Text(L10n.AIModels.importedLocalModel.text)
                    .font(.system(size: 11))
                    .foregroundColor(Color(.secondaryLabelColor))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                if isCurrent {
                    Text(L10n.AIModels.defaultModel.text)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabelColor))
                } else if isDownloaded {
                    Button(action: setDefaultAction) {
                        Text(L10n.AIModels.setAsDefault.text)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                if isDownloaded {
                    Menu {
                        Button(action: deleteAction) {
                            Label(L10n.AIModels.deleteModel.text, systemImage: "trash")
                        }
                    Button {
                        if let modelURL = modelURL {
                            NSWorkspace.shared.selectFile(modelURL.path, inFileViewerRootedAtPath: "")
                        }
                    } label: {
                        Label(L10n.AIModels.showInFinder.text, systemImage: "folder")
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
        .padding(16)
        .background(CardBackground(isSelected: isCurrent, useAccentGradientWhenSelected: isCurrent))
    }
}


// MARK: - Helper Views and Functions

func progressDotsWithNumber(value: Double) -> some View {
    HStack(spacing: 4) {
        progressDots(value: value)
        Text(String(format: "%.1f", value))
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(Color(.secondaryLabelColor))
    }
}

func progressDots(value: Double) -> some View {
    HStack(spacing: 2) {
        ForEach(0..<5) { index in
            Circle()
                .fill(index < Int(value / 2) ? performanceColor(value: value / 10) : Color(.quaternaryLabelColor))
                .frame(width: 6, height: 6)
        }
    }
}

func performanceColor(value: Double) -> Color {
    switch value {
    case 0.8...1.0: return Color(.systemGreen)
    case 0.6..<0.8: return Color(.systemYellow)
    case 0.4..<0.6: return Color(.systemOrange)
    default: return Color(.systemRed)
    }
}
