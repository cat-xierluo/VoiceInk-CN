import SwiftUI
import Combine
import AppKit

struct ParakeetModelCardRowView: View {
    let model: ParakeetModel
    @ObservedObject var whisperState: WhisperState

    var isCurrent: Bool {
        whisperState.currentTranscriptionModel?.name == model.name
    }

    var isDownloaded: Bool {
        whisperState.isParakeetModelDownloaded(model)
    }

    var isDownloading: Bool {
        whisperState.isParakeetModelDownloading(model)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                headerSection
                metadataSection
                descriptionSection
                progressSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
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
            
            Text(L10n.AIModels.experimental.text)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.orange.opacity(0.8)))
                .foregroundColor(.white)

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
            Label(localizedLanguageLabel, systemImage: "globe")
            Label(model.size, systemImage: "internaldrive")
            HStack(spacing: 3) {
                Text(L10n.AIModels.speed.text)
                progressDotsWithNumber(value: model.speed * 10)
            }
            .fixedSize(horizontal: true, vertical: false)
            HStack(spacing: 3) {
                Text(L10n.AIModels.accuracy.text)
                progressDotsWithNumber(value: model.accuracy * 10)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .font(.system(size: 11))
        .foregroundColor(Color(.secondaryLabelColor))
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

    private var progressSection: some View {
        Group {
            if isDownloading {
                let progress = whisperState.downloadProgress[model.name] ?? 0.0
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
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
                Button(action: {
                    Task {
                        await whisperState.setDefaultTranscriptionModel(model)
                    }
                }) {
                    Text(L10n.AIModels.setAsDefault.text)
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Button(action: {
                    Task {
                        await whisperState.downloadParakeetModel(model)
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isDownloading ? L10n.AIModels.downloading.text : L10n.AIModels.download.text)
                        Image(systemName: "arrow.down.circle")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.accentColor))
                }
                .buttonStyle(.plain)
                .disabled(isDownloading)
            }
            
            if isDownloaded {
                Menu {
                    Button(action: {
                         whisperState.deleteParakeetModel(model)
                    }) {
                        Label(L10n.AIModels.deleteModel.text, systemImage: "trash")
                    }
                    
                    Button {
                        whisperState.showParakeetModelInFinder(model)
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
    
    private var localizedLanguageLabel: LocalizedStringKey {
        model.isMultilingualModel ? L10n.AIModels.languageMultilingualShort.text : L10n.AIModels.languageEnglishOnlyShort.text
    }
}
