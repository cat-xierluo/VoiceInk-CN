import SwiftUI

struct PowerModeSettingsSection: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @AppStorage("powerModeUIFlag") private var powerModeUIFlag = false
    @AppStorage(PowerModeDefaults.autoRestoreKey) private var powerModeAutoRestoreEnabled = false
    @State private var showDisableAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles.square.fill.on.square")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.PowerMode.title.text)
                        .font(.headline)
                    Text(L10n.PowerMode.description.text)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle(L10n.PowerMode.enable.text, isOn: toggleBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }

            if powerModeUIFlag {
                Divider()
                    .padding(.vertical, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
                HStack(spacing: 8) {
                    Toggle(isOn: $powerModeAutoRestoreEnabled) {
                        Text(L10n.PowerMode.autoRestore.text)
                    }
                    .toggleStyle(.switch)

                    InfoTip(
                        title: L10n.PowerMode.autoRestore.string,
                        message: L10n.PowerMode.autoRestoreHelp.string
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: powerModeUIFlag)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CardBackground(isSelected: false, useAccentGradientWhenSelected: true))
        .alert(L10n.PowerMode.stillActive.text, isPresented: $showDisableAlert) {
            Button(L10n.PowerMode.gotIt.text, role: .cancel) { }
        } message: {
            Text(L10n.PowerMode.cantDisable.text)
        }
    }
    
    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { powerModeUIFlag },
            set: { newValue in
                if newValue {
                    powerModeUIFlag = true
                } else if powerModeManager.configurations.noneEnabled {
                    powerModeUIFlag = false
                } else {
                    showDisableAlert = true
                }
            }
        )
    }
    
}

private extension Array where Element == PowerModeConfig {
    var noneEnabled: Bool {
        allSatisfy { !$0.isEnabled }
    }
}

enum PowerModeDefaults {
    static let autoRestoreKey = "powerModeAutoRestoreEnabled"
}
