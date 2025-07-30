import SwiftUI
// Supporting Views

// VoiceInk's consistent button component
struct VoiceInkButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isDisabled ? Color.accentColor.opacity(0.5) : Color.accentColor)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct PowerModeEmptyStateView: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Power Modes")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add customized power modes for different contexts")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VoiceInkButton(
                title: "Add New Power Mode",
                action: action
            )
            .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PowerModeConfigurationsGrid: View {
    @ObservedObject var powerModeManager: PowerModeManager
    let onEditConfig: (PowerModeConfig) -> Void
    @EnvironmentObject var enhancementService: AIEnhancementService
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(powerModeManager.configurations) { config in
                ConfigurationRow(
                    config: config,
                    isEditing: false,
                    isDefault: false,
                    action: { 
                        onEditConfig(config)
                    }
                )
                .contextMenu {
                    Button(action: { 
                        onEditConfig(config)
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        powerModeManager.removeConfiguration(with: config.id)
                    }) {
                        Label("Remove", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ConfigurationRow: View {
    let config: PowerModeConfig
    let isEditing: Bool
    let isDefault: Bool
    let action: () -> Void
    @EnvironmentObject var enhancementService: AIEnhancementService
    @EnvironmentObject var whisperState: WhisperState
    
    // How many app icons to show at maximum
    private let maxAppIconsToShow = 5
    
    // Data properties
    private var selectedPrompt: CustomPrompt? {
        guard let promptId = config.selectedPrompt,
              let uuid = UUID(uuidString: promptId) else { return nil }
        return enhancementService.allPrompts.first { $0.id == uuid }
    }
    
    private var selectedModel: String? {
        if let modelName = config.selectedTranscriptionModelName,
           let model = whisperState.allAvailableModels.first(where: { $0.name == modelName }) {
            return model.displayName
        }
        return "Default"
    }
    
    private var selectedLanguage: String? {
        if let langCode = config.selectedLanguage {
            if langCode == "auto" { return "Auto" }
            if langCode == "en" { return "English" }
            
            if let modelName = config.selectedTranscriptionModelName,
               let model = whisperState.allAvailableModels.first(where: { $0.name == modelName }),
               let langName = model.supportedLanguages[langCode] {
                return langName
            }
            return langCode.uppercased()
        }
        return "Default"
    }
    
    private var appCount: Int { return config.appConfigs?.count ?? 0 }
    private var websiteCount: Int { return config.urlConfigs?.count ?? 0 }
    
    private var websiteText: String {
        if websiteCount == 0 { return "" }
        return websiteCount == 1 ? "1 Website" : "\(websiteCount) Websites"
    }
    
    private var appText: String {
        if appCount == 0 { return "" }
        return appCount == 1 ? "1 App" : "\(appCount) Apps"
    }
    
    private var extraAppsCount: Int {
        return max(0, appCount - maxAppIconsToShow)
    }
    
    private var visibleAppConfigs: [AppConfig] {
        return Array(config.appConfigs?.prefix(maxAppIconsToShow) ?? [])
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Top row: Emoji, Name, and App/Website counts
                HStack(spacing: 12) {
                    // Left: Emoji/Icon
                    ZStack {
                        Circle()
                            .fill(isDefault ? Color.accentColor.opacity(0.15) : Color(.controlBackgroundColor))
                            .frame(width: 40, height: 40)
                        
                        if isDefault {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.accentColor)
                        } else {
                            Text(config.emoji)
                                .font(.system(size: 20))
                        }
                    }
                    
                    // Middle: Name and badge
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(config.name)
                                .font(.system(size: 15, weight: .semibold))
                            
                            if isDefault {
                                Text("Default")
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        if isDefault {
                            Text("Fallback power mode")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Right: App Icons and Website Count
                    if !isDefault {
                        HStack(alignment: .center, spacing: 6) {
                            // App Count
                            if appCount > 0 {
                                HStack(spacing: 3) {
                                    Text(appText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "app.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Website Count
                            if websiteCount > 0 {
                                HStack(spacing: 3) {
                                    Text(websiteText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "globe")
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                
                // Only add divider and settings row if we have settings
                if selectedModel != nil || selectedLanguage != nil || config.isAIEnhancementEnabled {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Settings badges in specified order
                    HStack(spacing: 8) {
                        // 1. Voice Model badge
                        if let model = selectedModel, model != "Default" {
                            HStack(spacing: 4) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 10))
                                Text(model)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule()
                                .fill(Color(.controlBackgroundColor)))
                            .overlay(
                                Capsule()
                                    .stroke(Color(.separatorColor), lineWidth: 0.5)
                            )
                        }
                        
                        // 2. Language badge
                        if let language = selectedLanguage, language != "Default" {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                    .font(.system(size: 10))
                                Text(language)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule()
                                .fill(Color(.controlBackgroundColor)))
                            .overlay(
                                Capsule()
                                    .stroke(Color(.separatorColor), lineWidth: 0.5)
                            )
                        }
                        
                        // 3. AI Model badge if specified (moved before AI Enhancement)
                        if config.isAIEnhancementEnabled, let modelName = config.selectedAIModel, !modelName.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "cpu")
                                    .font(.system(size: 10))
                                // Display a shortened version of the model name if it's too long (increased limit)
                                Text(modelName.count > 20 ? String(modelName.prefix(18)) + "..." : modelName)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule()
                                .fill(Color(.controlBackgroundColor)))
                            .overlay(
                                Capsule()
                                    .stroke(Color(.separatorColor), lineWidth: 0.5)
                            )
                        }
                        
                        // 4. AI Enhancement badge
                        if config.isAIEnhancementEnabled {
                            // Context Awareness badge (moved before AI Enhancement)
                            if config.useScreenCapture {
                                HStack(spacing: 4) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 10))
                                    Text("Context Awareness")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule()
                                    .fill(Color(.controlBackgroundColor)))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(.separatorColor), lineWidth: 0.5)
                                )
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 10))
                                Text(selectedPrompt?.title ?? "AI")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule()
                                .fill(Color.accentColor.opacity(0.1)))
                            .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                }
            }
            .background(CardBackground(isSelected: isEditing))
        }
        .buttonStyle(.plain)
    }
    
    private var isSelected: Bool {
        return isEditing
    }
}

// App Icon View Component
struct PowerModeAppIcon: View {
    let bundleId: String
    
    var body: some View {
        if let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: appUrl.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
        } else {
            Image(systemName: "app.fill")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
        }
    }
}

struct AppGridItem: View {
    let app: (url: URL, name: String, bundleId: String, icon: NSImage)
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .shadow(color: Color(NSColor.shadowColor).opacity(0.1), radius: 2, x: 0, y: 1)
                Text(app.name)
                    .font(.system(size: 10))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 28)
            }
            .frame(width: 80, height: 80)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
} 
