import SwiftUI

<<<<<<< HEAD
// Power Mode Popover for recorder views
=======
>>>>>>> upstream/main
struct PowerModePopover: View {
    @ObservedObject var powerModeManager = PowerModeManager.shared
    @State private var selectedConfig: PowerModeConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("Select Power Mode", comment: "Select Power Mode"))
=======
            Text("Select Power Mode")
>>>>>>> upstream/main
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
                .padding(.top, 8)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            ScrollView {
<<<<<<< HEAD
                VStack(alignment: .leading, spacing: 4) {
                    // Default Configuration
                    PowerModeRow(
                        config: powerModeManager.defaultConfig,
                        isSelected: selectedConfig?.id == powerModeManager.defaultConfig.id,
                        action: {
                            powerModeManager.setActiveConfiguration(powerModeManager.defaultConfig)
                            selectedConfig = powerModeManager.defaultConfig
                            // Apply configuration immediately
                            applySelectedConfiguration()
                        }
                    )
                    
                    // Custom Configurations
                    ForEach(powerModeManager.configurations) { config in
                        PowerModeRow(
                            config: config,
                            isSelected: selectedConfig?.id == config.id,
                            action: {
                                powerModeManager.setActiveConfiguration(config)
                                selectedConfig = config
                                // Apply configuration immediately
                                applySelectedConfiguration()
                            }
                        )
=======
                let enabledConfigs = powerModeManager.configurations.filter { $0.isEnabled }
                VStack(alignment: .leading, spacing: 4) {
                    if enabledConfigs.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(size: 16))
                            Text("No Power Modes Available")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else {
                        ForEach(enabledConfigs) { config in
                            PowerModeRow(
                                config: config,
                                isSelected: selectedConfig?.id == config.id,
                                action: {
                                    powerModeManager.setActiveConfiguration(config)
                                    selectedConfig = config
                                    applySelectedConfiguration()
                                }
                            )
                        }
>>>>>>> upstream/main
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 180)
<<<<<<< HEAD
        .frame(maxHeight: 300)
=======
        .frame(maxHeight: 340)
>>>>>>> upstream/main
        .padding(.vertical, 8)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .onAppear {
<<<<<<< HEAD
            // Set the initially selected configuration
            selectedConfig = powerModeManager.activeConfiguration
        }
    }
    
    // Helper function to apply the selected configuration
    private func applySelectedConfiguration() {
        Task {
            if let config = selectedConfig {
                await ActiveWindowService.shared.applyConfiguration(config)
=======
            selectedConfig = powerModeManager.activeConfiguration
        }
        .onChange(of: powerModeManager.activeConfiguration) { newValue in
            selectedConfig = newValue
        }
    }
    
    private func applySelectedConfiguration() {
        Task {
            if let config = selectedConfig {
                await PowerModeSessionManager.shared.beginSession(with: config)
>>>>>>> upstream/main
            }
        }
    }
}

<<<<<<< HEAD
// Row view for each power mode in the popover
=======
>>>>>>> upstream/main
struct PowerModeRow: View {
    let config: PowerModeConfig
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
<<<<<<< HEAD
                // Always use the emoji from the configuration
                Text(config.emoji)
                    .font(.system(size: 14))
                
=======
                Text(config.emoji)
                    .font(.system(size: 14))

>>>>>>> upstream/main
                Text(config.name)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 13))
                    .lineLimit(1)
<<<<<<< HEAD
                
=======

>>>>>>> upstream/main
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 10))
                }
            }
<<<<<<< HEAD
            .contentShape(Rectangle())
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
=======
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
>>>>>>> upstream/main
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
<<<<<<< HEAD
} 
=======
} 
>>>>>>> upstream/main
