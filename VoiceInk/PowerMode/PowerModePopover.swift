import SwiftUI

// Power Mode Popover for recorder views
struct PowerModePopover: View {
    @ObservedObject var powerModeManager = PowerModeManager.shared
    @State private var selectedConfig: PowerModeConfig?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Power Mode")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
                .padding(.top, 8)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            ScrollView {
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
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 180)
        .frame(maxHeight: 300)
        .padding(.vertical, 8)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .onAppear {
            // Set the initially selected configuration
            selectedConfig = powerModeManager.activeConfiguration
        }
    }
    
    // Helper function to apply the selected configuration
    private func applySelectedConfiguration() {
        Task {
            if let config = selectedConfig {
                await ActiveWindowService.shared.applyConfiguration(config)
            }
        }
    }
}

// Row view for each power mode in the popover
struct PowerModeRow: View {
    let config: PowerModeConfig
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Always use the emoji from the configuration
                Text(config.emoji)
                    .font(.system(size: 14))
                
                Text(config.name)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 13))
                    .lineLimit(1)
                
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 10))
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
} 