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

<<<<<<< HEAD
// Configuration Mode Enum
enum ConfigurationMode: Hashable {
    case add
    case edit(PowerModeConfig)
    case editDefault(PowerModeConfig)
=======
enum ConfigurationMode: Hashable {
    case add
    case edit(PowerModeConfig)
>>>>>>> upstream/main
    
    var isAdding: Bool {
        if case .add = self { return true }
        return false
    }
    
<<<<<<< HEAD
    var isEditingDefault: Bool {
        if case .editDefault = self { return true }
        return false
    }
    
    var title: String {
        switch self {
case .add: return NSLocalizedString("Add Power Mode", comment: "Add Power Mode")
case .editDefault: return NSLocalizedString("Edit Default Power Mode", comment: "Edit Default Power Mode")
case .edit: return NSLocalizedString("Edit Power Mode", comment: "Edit Power Mode")
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
=======
    var title: String {
        switch self {
        case .add: return "Add Power Mode"
        case .edit: return "Edit Power Mode"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .add:
            hasher.combine(0)
        case .edit(let config):
            hasher.combine(1)
>>>>>>> upstream/main
            hasher.combine(config.id)
        }
    }
    
<<<<<<< HEAD
    // Implement == to conform to Equatable (required by Hashable)
=======
>>>>>>> upstream/main
    static func == (lhs: ConfigurationMode, rhs: ConfigurationMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add):
            return true
        case (.edit(let lhsConfig), .edit(let rhsConfig)):
            return lhsConfig.id == rhsConfig.id
<<<<<<< HEAD
        case (.editDefault(let lhsConfig), .editDefault(let rhsConfig)):
            return lhsConfig.id == rhsConfig.id
=======
>>>>>>> upstream/main
        default:
            return false
        }
    }
}

<<<<<<< HEAD
// Configuration Type
=======
>>>>>>> upstream/main
enum ConfigurationType {
    case application
    case website
}

<<<<<<< HEAD
// Common Emojis for selection
let commonEmojis = ["🏢", "🏠", "💼", "🎮", "📱", "📺", "🎵", "📚", "✏️", "🎨", "🧠", "⚙️", "💻", "🌐", "📝", "📊", "🔍", "💬", "📈", "🔧"]

// Main Power Mode View with Navigation
=======
let commonEmojis = ["🏢", "🏠", "💼", "🎮", "📱", "📺", "🎵", "📚", "✏️", "🎨", "🧠", "⚙️", "💻", "🌐", "📝", "📊", "🔍", "💬", "📈", "🔧"]

>>>>>>> upstream/main
struct PowerModeView: View {
    @StateObject private var powerModeManager = PowerModeManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var aiService: AIService
    @State private var configurationMode: ConfigurationMode?
    @State private var navigationPath = NavigationPath()
<<<<<<< HEAD
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center) {
Text(NSLocalizedString("Power Mode", comment: "Power Mode"))
                                .font(.system(size: 22, weight: .bold))
                            
                            InfoTip(
title: NSLocalizedString("Power Mode", comment: "Power Mode"),
message: NSLocalizedString("Create custom modes that automatically apply when using specific apps/websites.", comment: "Create custom modes that automatically apply when using specific apps/websites."),
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
                        
Text(NSLocalizedString("Automatically apply custom configurations based on the app/website you are using", comment: "Automatically apply custom configurations based on the app/website you are using"))
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
Text(NSLocalizedString("Default Power Mode", comment: "Default Power Mode"))
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
Text(NSLocalizedString("Custom Power Modes", comment: "Custom Power Modes"))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                if powerModeManager.configurations.isEmpty {
                                    VStack(spacing: 20) {
                                        Image(systemName: "square.grid.2x2")
                                            .font(.system(size: 36))
                                            .foregroundColor(.secondary)
                                        
Text(NSLocalizedString("No custom power modes", comment: "No custom power modes"))
                                            .font(.title3)
                                            .fontWeight(.medium)
                                        
Text(NSLocalizedString("Create a new mode for specific apps/websites", comment: "Create a new mode for specific apps/websites"))
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
title: NSLocalizedString("Add New Power Mode", comment: "Add New Power Mode"),
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
                            
Text(NSLocalizedString("Power Mode is disabled", comment: "Power Mode is disabled"))
                                .font(.title2)
                                .fontWeight(.semibold)
                            
Text(NSLocalizedString("Enable Power Mode to create context-specific configurations that automatically apply based on your current app or website.", comment: "Enable Power Mode to create context-specific configurations that automatically apply based on your current app or website."))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 400)
                            
                            VoiceInkButton(
title: NSLocalizedString("Enable Power Mode", comment: "Enable Power Mode"),
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
=======
    @State private var isReorderMode = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("Power Modes")
                                    .font(.system(size: 28, weight: .bold, design: .default))
                                    .foregroundColor(.primary)
                                
                                                                 InfoTip(
                                     title: "What is Power Mode?",
                                     message: "Automatically apply custom configurations based on the app/website you are using",
                                     learnMoreURL: "https://www.youtube.com/@tryvoiceink/videos"
                                 )
                            }
                            
                            Text("Automate your workflows with context-aware configurations.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            if !isReorderMode {
                                Button(action: {
                                    configurationMode = .add
                                    navigationPath.append(configurationMode!)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 12, weight: .medium))
                                        Text("Add Power Mode")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor)
                                    .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Button(action: { withAnimation { isReorderMode.toggle() } }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isReorderMode ? "checkmark" : "arrow.up.arrow.down")
                                        .font(.system(size: 12, weight: .medium))
                                    Text(isReorderMode ? "Done" : "Reorder")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Rectangle()
                    .fill(Color(NSColor.separatorColor))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                
                if isReorderMode {
                    VStack(spacing: 12) {
                        List {
                            ForEach(powerModeManager.configurations) { config in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(NSColor.controlBackgroundColor))
                                            .frame(width: 40, height: 40)
                                        Text(config.emoji)
                                            .font(.system(size: 20))
                                    }

                                    Text(config.name)
                                        .font(.system(size: 15, weight: .semibold))

                                    Spacer()

                                    HStack(spacing: 6) {
                                        if config.isDefault {
                                            Text("Default")
                                                .font(.system(size: 11, weight: .medium))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(Color.accentColor))
                                                .foregroundColor(.white)
                                        }
                                        if !config.isEnabled {
                                            Text("Disabled")
                                                .font(.system(size: 11, weight: .medium))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Capsule().fill(Color(NSColor.controlBackgroundColor)))
                                                .overlay(
                                                    Capsule().stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                                                )
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(CardBackground(isSelected: false))
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 6)
                            }
                            .onMove(perform: powerModeManager.moveConfigurations)
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.controlBackgroundColor))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 0) {
                                if powerModeManager.configurations.isEmpty {
                                    VStack(spacing: 24) {
                                        Spacer()
                                            .frame(height: geometry.size.height * 0.2)
                                        
                                        VStack(spacing: 16) {
                                            Image(systemName: "square.grid.2x2.fill")
                                                .font(.system(size: 48, weight: .regular))
                                                .foregroundColor(.secondary.opacity(0.6))
                                            
                                            VStack(spacing: 8) {
                                                Text("No Power Modes Yet")
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(.primary)
                                                
                                                Text("Create first power mode to automate your VoiceInk workflow based on apps/website you are using")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.secondary)
                                                    .multilineTextAlignment(.center)
                                                    .lineSpacing(2)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: geometry.size.height)
                                } else {
                                    VStack(spacing: 0) {
                                        PowerModeConfigurationsGrid(
                                            powerModeManager: powerModeManager,
                                            onEditConfig: { config in
                                                configurationMode = .edit(config)
                                                navigationPath.append(configurationMode!)
                                            }
                                        )
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 20)
                                        
                                        Spacer()
                                            .frame(height: 40)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
>>>>>>> upstream/main
            .navigationDestination(for: ConfigurationMode.self) { mode in
                ConfigurationView(mode: mode, powerModeManager: powerModeManager)
            }
        }
    }
}


<<<<<<< HEAD
=======

>>>>>>> upstream/main
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
