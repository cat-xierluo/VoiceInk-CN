import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Configuration Mode Enum
enum ConfigurationMode: Hashable {
    case add
    case edit(PowerModeConfig)
    case editDefault(PowerModeConfig)
    
    var isAdding: Bool {
        if case .add = self { return true }
        return false
    }
    
    var isEditingDefault: Bool {
        if case .editDefault = self { return true }
        return false
    }
    
    var title: String {
        switch self {
        case .add: return "Add Power Mode"
        case .editDefault: return "Edit Default Power Mode"
        case .edit: return "Edit Power Mode"
        }
    }
    
    // Implement hash(into:) to conform to Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .add:
            hasher.combine(0) // Use a unique value for add
        case .edit(let config):
            hasher.combine(1) // Use a unique value for edit
            hasher.combine(config.id)
        case .editDefault(let config):
            hasher.combine(2) // Use a unique value for editDefault
            hasher.combine(config.id)
        }
    }
    
    // Implement == to conform to Equatable (required by Hashable)
    static func == (lhs: ConfigurationMode, rhs: ConfigurationMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add):
            return true
        case (.edit(let lhsConfig), .edit(let rhsConfig)):
            return lhsConfig.id == rhsConfig.id
        case (.editDefault(let lhsConfig), .editDefault(let rhsConfig)):
            return lhsConfig.id == rhsConfig.id
        default:
            return false
        }
    }
}

// Configuration Type
enum ConfigurationType {
    case application
    case website
}

// Common Emojis for selection
let commonEmojis = ["🏢", "🏠", "💼", "🎮", "📱", "📺", "🎵", "📚", "✏️", "🎨", "🧠", "⚙️", "💻", "🌐", "📝", "📊", "🔍", "💬", "📈", "🔧"]

// Main Power Mode View with Navigation
struct PowerModeView: View {
    @StateObject private var powerModeManager = PowerModeManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService
    @State private var configurationMode: ConfigurationMode?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center) {
                            Text("Power Mode")
                                .font(.system(size: 22, weight: .bold))
                            
                            InfoTip(
                                title: "Power Mode",
                                message: "Create custom modes that automatically apply when using specific apps/websites.",
                                learnMoreURL: "https://www.youtube.com/watch?v=cEepexxgf6Y&t=10s"
                            )
                            
                            Spacer()
                            
                            Toggle("", isOn: $powerModeManager.isPowerModeEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .labelsHidden()
                                .scaleEffect(1.2)
                                .onChange(of: powerModeManager.isPowerModeEnabled) { oldValue, newValue in
                                    powerModeManager.savePowerModeEnabled()
                                }
                        }
                        
                        Text("Automatically apply custom configurations based on the app/website you are using")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if powerModeManager.isPowerModeEnabled {
                        // Configurations Container
                        VStack(spacing: 0) {
                            // Default Configuration Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Default Power Mode")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                
                                ConfigurationRow(
                                    config: powerModeManager.defaultConfig,
                                    isEditing: false,
                                    isDefault: true,
                                    action: { 
                                        configurationMode = .editDefault(powerModeManager.defaultConfig)
                                        navigationPath.append(configurationMode!)
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            // Divider between sections
                            Divider()
                                .padding(.vertical, 16)
                            
                            // Custom Configurations Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Custom Power Modes")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                if powerModeManager.configurations.isEmpty {
                                    VStack(spacing: 20) {
                                        Image(systemName: "square.grid.2x2")
                                            .font(.system(size: 36))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No custom power modes")
                                            .font(.title3)
                                            .fontWeight(.medium)
                                        
                                        Text("Create a new mode for specific apps/websites")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 30)
                                } else {
                                    PowerModeConfigurationsGrid(
                                        powerModeManager: powerModeManager,
                                        onEditConfig: { config in
                                            configurationMode = .edit(config)
                                            navigationPath.append(configurationMode!)
                                        }
                                    )
                                }
                            }
                            
                            Spacer(minLength: 24)
                            
                            // Add Configuration button at the bottom (centered)
                            HStack {
                                VoiceInkButton(
                                    title: "Add New Power Mode",
                                    action: {
                                        configurationMode = .add
                                        navigationPath.append(configurationMode!)
                                    }
                                )
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(NSColor.controlBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                        .shadow(color: Color(NSColor.shadowColor).opacity(0.05), radius: 5, y: 2)
                        .padding(.horizontal)
                    } else {
                        // Disabled state
                        VStack(spacing: 24) {
                            Image(systemName: "bolt.slash.circle")
                                .font(.system(size: 56))
                                .foregroundColor(.secondary)
                            
                            Text("Power Mode is disabled")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Enable Power Mode to create context-specific configurations that automatically apply based on your current app or website.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 400)
                            
                            VoiceInkButton(
                                title: "Enable Power Mode",
                                action: {
                                    powerModeManager.isPowerModeEnabled = true
                                    powerModeManager.savePowerModeEnabled()
                                }
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(16)
                        .shadow(color: Color(NSColor.shadowColor).opacity(0.05), radius: 5, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .navigationTitle("")
            .navigationDestination(for: ConfigurationMode.self) { mode in
                ConfigurationView(mode: mode, powerModeManager: powerModeManager)
            }
        }
    }
}


// New component for section headers
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}
