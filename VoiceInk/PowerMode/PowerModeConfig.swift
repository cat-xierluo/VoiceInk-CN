import Foundation

struct PowerModeConfig: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var emoji: String
    var appConfigs: [AppConfig]?
    var urlConfigs: [URLConfig]?
    var isAIEnhancementEnabled: Bool
    var selectedPrompt: String?
    var selectedTranscriptionModelName: String?
    var selectedLanguage: String?
    var useScreenCapture: Bool
    var selectedAIProvider: String?
    var selectedAIModel: String?
    // NEW: Automatically press the Return key after pasting
    var isAutoSendEnabled: Bool = false
        
    // Custom coding keys to handle migration from selectedWhisperModel
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, appConfigs, urlConfigs, isAIEnhancementEnabled, selectedPrompt, selectedLanguage, useScreenCapture, selectedAIProvider, selectedAIModel, isAutoSendEnabled
        case selectedWhisperModel // Old key
        case selectedTranscriptionModelName // New key
    }
    
    init(id: UUID = UUID(), name: String, emoji: String, appConfigs: [AppConfig]? = nil,
         urlConfigs: [URLConfig]? = nil, isAIEnhancementEnabled: Bool, selectedPrompt: String? = nil,
         selectedTranscriptionModelName: String? = nil, selectedLanguage: String? = nil, useScreenCapture: Bool = false,
         selectedAIProvider: String? = nil, selectedAIModel: String? = nil, isAutoSendEnabled: Bool = false) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.appConfigs = appConfigs
        self.urlConfigs = urlConfigs
        self.isAIEnhancementEnabled = isAIEnhancementEnabled
        self.selectedPrompt = selectedPrompt
        self.useScreenCapture = useScreenCapture
        self.isAutoSendEnabled = isAutoSendEnabled
        self.selectedAIProvider = selectedAIProvider ?? UserDefaults.standard.string(forKey: "selectedAIProvider")
        self.selectedAIModel = selectedAIModel
        self.selectedTranscriptionModelName = selectedTranscriptionModelName ?? UserDefaults.standard.string(forKey: "CurrentTranscriptionModel")
        self.selectedLanguage = selectedLanguage ?? UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        appConfigs = try container.decodeIfPresent([AppConfig].self, forKey: .appConfigs)
        urlConfigs = try container.decodeIfPresent([URLConfig].self, forKey: .urlConfigs)
        isAIEnhancementEnabled = try container.decode(Bool.self, forKey: .isAIEnhancementEnabled)
        selectedPrompt = try container.decodeIfPresent(String.self, forKey: .selectedPrompt)
        selectedLanguage = try container.decodeIfPresent(String.self, forKey: .selectedLanguage)
        useScreenCapture = try container.decode(Bool.self, forKey: .useScreenCapture)
        selectedAIProvider = try container.decodeIfPresent(String.self, forKey: .selectedAIProvider)
        selectedAIModel = try container.decodeIfPresent(String.self, forKey: .selectedAIModel)
        isAutoSendEnabled = try container.decodeIfPresent(Bool.self, forKey: .isAutoSendEnabled) ?? false

        if let newModelName = try container.decodeIfPresent(String.self, forKey: .selectedTranscriptionModelName) {
            selectedTranscriptionModelName = newModelName
        } else if let oldModelName = try container.decodeIfPresent(String.self, forKey: .selectedWhisperModel) {
            selectedTranscriptionModelName = oldModelName
        } else {
            selectedTranscriptionModelName = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(emoji, forKey: .emoji)
        try container.encodeIfPresent(appConfigs, forKey: .appConfigs)
        try container.encodeIfPresent(urlConfigs, forKey: .urlConfigs)
        try container.encode(isAIEnhancementEnabled, forKey: .isAIEnhancementEnabled)
        try container.encodeIfPresent(selectedPrompt, forKey: .selectedPrompt)
        try container.encodeIfPresent(selectedLanguage, forKey: .selectedLanguage)
        try container.encode(useScreenCapture, forKey: .useScreenCapture)
        try container.encodeIfPresent(selectedAIProvider, forKey: .selectedAIProvider)
        try container.encodeIfPresent(selectedAIModel, forKey: .selectedAIModel)
        try container.encode(isAutoSendEnabled, forKey: .isAutoSendEnabled)
        try container.encodeIfPresent(selectedTranscriptionModelName, forKey: .selectedTranscriptionModelName)
    }
    
    
    static func == (lhs: PowerModeConfig, rhs: PowerModeConfig) -> Bool {
        lhs.id == rhs.id
    }
}

// App configuration
struct AppConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var bundleIdentifier: String
    var appName: String
    
    init(id: UUID = UUID(), bundleIdentifier: String, appName: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
    }
    
    static func == (lhs: AppConfig, rhs: AppConfig) -> Bool {
        lhs.id == rhs.id
    }
}

// Simple URL configuration
struct URLConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var url: String // Simple URL like "google.com"
    
    init(id: UUID = UUID(), url: String) {
        self.id = id
        self.url = url
    }
    
    static func == (lhs: URLConfig, rhs: URLConfig) -> Bool {
        lhs.id == rhs.id
    }
}

class PowerModeManager: ObservableObject {
    static let shared = PowerModeManager()
    @Published var configurations: [PowerModeConfig] = []
    @Published var defaultConfig: PowerModeConfig
    @Published var isPowerModeEnabled: Bool
    @Published var activeConfiguration: PowerModeConfig?
    
    private let configKey = "powerModeConfigurationsV2"
    private let defaultConfigKey = "defaultPowerModeConfigV2"
    private let powerModeEnabledKey = "isPowerModeEnabled"
    private let activeConfigIdKey = "activeConfigurationId"
    
    private init() {
        // Load power mode enabled state or default to false if not set
        if UserDefaults.standard.object(forKey: powerModeEnabledKey) != nil {
            self.isPowerModeEnabled = UserDefaults.standard.bool(forKey: powerModeEnabledKey)
        } else {
            self.isPowerModeEnabled = false
            UserDefaults.standard.set(false, forKey: powerModeEnabledKey)
        }
        
        // Initialize default config with default values
        if let data = UserDefaults.standard.data(forKey: defaultConfigKey),
           let config = try? JSONDecoder().decode(PowerModeConfig.self, from: data) {
            defaultConfig = config
        } else {
            // Get default values from UserDefaults if available
            let defaultModelName = UserDefaults.standard.string(forKey: "CurrentTranscriptionModel")
            let defaultLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            
            defaultConfig = PowerModeConfig(
                id: UUID(),
                name: "Default Configuration",
                emoji: "⚙️",
                isAIEnhancementEnabled: false,
                selectedPrompt: nil,
                selectedTranscriptionModelName: defaultModelName,
                selectedLanguage: defaultLanguage
            )
            saveDefaultConfig()
        }
        loadConfigurations()
        
        // Set the active configuration, either from saved ID or default to the default config
        if let activeConfigIdString = UserDefaults.standard.string(forKey: activeConfigIdKey),
           let activeConfigId = UUID(uuidString: activeConfigIdString) {
            if let savedConfig = configurations.first(where: { $0.id == activeConfigId }) {
                activeConfiguration = savedConfig
            } else if activeConfigId == defaultConfig.id {
                activeConfiguration = defaultConfig
            } else {
                activeConfiguration = defaultConfig
            }
        } else {
            activeConfiguration = defaultConfig
        }
    }
    
    private func loadConfigurations() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let configs = try? JSONDecoder().decode([PowerModeConfig].self, from: data) {
            configurations = configs
        }
    }
    
    func saveConfigurations() {
        if let data = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
    
    private func saveDefaultConfig() {
        if let data = try? JSONEncoder().encode(defaultConfig) {
            UserDefaults.standard.set(data, forKey: defaultConfigKey)
        }
    }
    
    func addConfiguration(_ config: PowerModeConfig) {
        if !configurations.contains(where: { $0.id == config.id }) {
            configurations.append(config)
            saveConfigurations()
        }
    }
    
    func removeConfiguration(with id: UUID) {
        configurations.removeAll { $0.id == id }
        saveConfigurations()
    }
    
    func getConfiguration(with id: UUID) -> PowerModeConfig? {
        return configurations.first { $0.id == id }
    }
    
    func updateConfiguration(_ config: PowerModeConfig) {
        if config.id == defaultConfig.id {
            defaultConfig = config
            saveDefaultConfig()
        } else if let index = configurations.firstIndex(where: { $0.id == config.id }) {
            configurations[index] = config
            saveConfigurations()
        }
    }
    
    // Get configuration for a specific URL
    func getConfigurationForURL(_ url: String) -> PowerModeConfig? {
        let cleanedURL = cleanURL(url)
        
        for config in configurations {
            if let urlConfigs = config.urlConfigs {
                for urlConfig in urlConfigs {
                    let configURL = cleanURL(urlConfig.url)
                    
                    if cleanedURL.contains(configURL) {
                        return config
                    }
                }
            }
        }
        return nil
    }
    
    // Get configuration for an application bundle ID
    func getConfigurationForApp(_ bundleId: String) -> PowerModeConfig? {
        for config in configurations {
            if let appConfigs = config.appConfigs {
                if appConfigs.contains(where: { $0.bundleIdentifier == bundleId }) {
                    return config
                }
            }
        }
        return nil
    }
    
    // Add app configuration
    func addAppConfig(_ appConfig: AppConfig, to config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            var configs = updatedConfig.appConfigs ?? []
            configs.append(appConfig)
            updatedConfig.appConfigs = configs
            updateConfiguration(updatedConfig)
        }
    }
    
    // Remove app configuration
    func removeAppConfig(_ appConfig: AppConfig, from config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            updatedConfig.appConfigs?.removeAll(where: { $0.id == appConfig.id })
            updateConfiguration(updatedConfig)
        }
    }
    
    // Add URL configuration
    func addURLConfig(_ urlConfig: URLConfig, to config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            var configs = updatedConfig.urlConfigs ?? []
            configs.append(urlConfig)
            updatedConfig.urlConfigs = configs
            updateConfiguration(updatedConfig)
        }
    }
    
    // Remove URL configuration
    func removeURLConfig(_ urlConfig: URLConfig, from config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            updatedConfig.urlConfigs?.removeAll(where: { $0.id == urlConfig.id })
            updateConfiguration(updatedConfig)
        }
    }
    
    // Clean URL for comparison
    func cleanURL(_ url: String) -> String {
        return url.lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Save power mode enabled state
    func savePowerModeEnabled() {
        UserDefaults.standard.set(isPowerModeEnabled, forKey: powerModeEnabledKey)
    }
    
    // Set active configuration
    func setActiveConfiguration(_ config: PowerModeConfig) {
        activeConfiguration = config
        UserDefaults.standard.set(config.id.uuidString, forKey: activeConfigIdKey)
        self.objectWillChange.send()
    }
    
    // Get current active configuration
    var currentActiveConfiguration: PowerModeConfig {
        return activeConfiguration ?? defaultConfig
    }
    
    // Get all available configurations in order (default first, then custom configurations)
    func getAllAvailableConfigurations() -> [PowerModeConfig] {
        return [defaultConfig] + configurations
    }
    
    func isEmojiInUse(_ emoji: String) -> Bool {
        if defaultConfig.emoji == emoji {
            return true
        }
        return configurations.contains { $0.emoji == emoji }
    }
} 