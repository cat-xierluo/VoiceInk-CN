import SwiftUI

struct ExperimentalFeaturesSection: View {
    @AppStorage("isExperimentalFeaturesEnabled") private var isExperimentalFeaturesEnabled = false
    @ObservedObject private var playbackController = PlaybackController.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "flask")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.SettingsExtended.ExperimentalFeatures.title.text)
                        .font(.headline)
                    Text(L10n.SettingsExtended.ExperimentalFeatures.description.text)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle(L10n.SettingsExtended.ExperimentalFeatures.toggleLabel.text, isOn: $isExperimentalFeaturesEnabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .onChange(of: isExperimentalFeaturesEnabled) { _, newValue in
                        if !newValue {
                            playbackController.isPauseMediaEnabled = false
                        }
                    }
            }

            if isExperimentalFeaturesEnabled {
                Divider()
                    .padding(.vertical, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
                Toggle(isOn: $playbackController.isPauseMediaEnabled) {
                    Text(L10n.SettingsExtended.ExperimentalFeatures.pauseMedia.text)
                }
                .toggleStyle(.switch)
                .help(L10n.SettingsExtended.ExperimentalFeatures.pauseMediaHelp.text)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExperimentalFeaturesEnabled)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CardBackground(isSelected: false, useAccentGradientWhenSelected: true))
    }
}
