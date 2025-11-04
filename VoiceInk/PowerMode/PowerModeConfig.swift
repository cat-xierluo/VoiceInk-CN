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
<<<<<<< HEAD
    // NEW: Automatically press the Return key after pasting
    var isAutoSendEnabled: Bool = false
        
    // Custom coding keys to handle migration from selectedWhisperModel
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, appConfigs, urlConfigs, isAIEnhancementEnabled, selectedPrompt, selectedLanguage, useScreenCapture, selectedAIProvider, selectedAIModel, isAutoSendEnabled
        case selectedWhisperModel // Old key
        case selectedTranscriptionModelName // New key
=======
    var isAutoSendEnabled: Bool = false
    var isEnabled: Bool = true
    var isDefault: Bool = false
        
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, appConfigs, urlConfigs, isAIEnhancementEnabled, selectedPrompt, selectedLanguage, useScreenCapture, selectedAIProvider, selectedAIModel, isAutoSendEnabled, isEnabled, isDefault
        case selectedWhisperModel
        case selectedTranscriptionModelName
>>>>>>> upstream/main
    }
    
    init(id: UUID = UUID(), name: String, emoji: String, appConfigs: [AppConfig]? = nil,
         urlConfigs: [URLConfig]? = nil, isAIEnhancementEnabled: Bool, selectedPrompt: String? = nil,
         selectedTranscriptionModelName: String? = nil, selectedLanguage: String? = nil, useScreenCapture: Bool = false,
<<<<<<< HEAD
         selectedAIProvider: String? = nil, selectedAIModel: String? = nil, isAutoSendEnabled: Bool = false) {
=======
         selectedAIProvider: String? = nil, selectedAIModel: String? = nil, isAutoSendEnabled: Bool = false, isEnabled: Bool = true, isDefault: Bool = false) {
>>>>>>> upstream/main
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
<<<<<<< HEAD
=======
        self.isEnabled = isEnabled
        self.isDefault = isDefault
>>>>>>> upstream/main
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
<<<<<<< HEAD
=======
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
>>>>>>> upstream/main

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
<<<<<<< HEAD
=======
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(isDefault, forKey: .isDefault)
>>>>>>> upstream/main
    }
    
    
    static func == (lhs: PowerModeConfig, rhs: PowerModeConfig) -> Bool {
        lhs.id == rhs.id
    }
}

<<<<<<< HEAD
// App configuration
=======
>>>>>>> upstream/main
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

<<<<<<< HEAD
// Simple URL configuration
struct URLConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var url: String // Simple URL like "google.com"
=======
struct URLConfig: Codable, Identifiable, Equatable {
    let id: UUID
    var url: String
>>>>>>> upstream/main
    
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
<<<<<<< HEAD
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
name: NSLocalizedString("Default Configuration", comment: "Default Configuration"),
                emoji: NSLocalizedString("⚙️", comment: "⚙️"),
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
    
=======
    @Published var activeConfiguration: PowerModeConfig?

    private let configKey = "powerModeConfigurationsV2"
    private let activeConfigIdKey = "activeConfigurationId"

    private init() {
        loadConfigurations()

        if let activeConfigIdString = UserDefaults.standard.string(forKey: activeConfigIdKey),
           let activeConfigId = UUID(uuidString: activeConfigIdString) {
            activeConfiguration = configurations.first { $0.id == activeConfigId }
        } else {
            activeConfiguration = nil
        }
    }

>>>>>>> upstream/main
    private func loadConfigurations() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let configs = try? JSONDecoder().decode([PowerModeConfig].self, from: data) {
            configurations = configs
        }
    }
<<<<<<< HEAD
    
=======

>>>>>>> upstream/main
    func saveConfigurations() {
        if let data = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
<<<<<<< HEAD
    
    private func saveDefaultConfig() {
        if let data = try? JSONEncoder().encode(defaultConfig) {
            UserDefaults.standard.set(data, forKey: defaultConfigKey)
        }
    }
    
=======

>>>>>>> upstream/main
    func addConfiguration(_ config: PowerModeConfig) {
        if !configurations.contains(where: { $0.id == config.id }) {
            configurations.append(config)
            saveConfigurations()
        }
    }
<<<<<<< HEAD
    
=======

>>>>>>> upstream/main
    func removeConfiguration(with id: UUID) {
        configurations.removeAll { $0.id == id }
        saveConfigurations()
    }
<<<<<<< HEAD
    
    func getConfiguration(with id: UUID) -> PowerModeConfig? {
        return configurations.first { $0.id == id }
    }
    
    func updateConfiguration(_ config: PowerModeConfig) {
        if config.id == defaultConfig.id {
            defaultConfig = config
            saveDefaultConfig()
        } else if let index = configurations.firstIndex(where: { $0.id == config.id }) {
=======

    func getConfiguration(with id: UUID) -> PowerModeConfig? {
        return configurations.first { $0.id == id }
    }

    func updateConfiguration(_ config: PowerModeConfig) {
        if let index = configurations.firstIndex(where: { $0.id == config.id }) {
>>>>>>> upstream/main
            configurations[index] = config
            saveConfigurations()
        }
    }
<<<<<<< HEAD
    
    // Get configuration for a specific URL
    func getConfigurationForURL(_ url: String) -> PowerModeConfig? {
        let cleanedURL = cleanURL(url)
        
        for config in configurations {
=======

    func moveConfigurations(fromOffsets: IndexSet, toOffset: Int) {
        configurations.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveConfigurations()
    }

    func getConfigurationForURL(_ url: String) -> PowerModeConfig? {
        let cleanedURL = cleanURL(url)
        
        for config in configurations.filter({ $0.isEnabled }) {
>>>>>>> upstream/main
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
    
<<<<<<< HEAD
    // Get configuration for an application bundle ID
    func getConfigurationForApp(_ bundleId: String) -> PowerModeConfig? {
        for config in configurations {
=======
    func getConfigurationForApp(_ bundleId: String) -> PowerModeConfig? {
        for config in configurations.filter({ $0.isEnabled }) {
>>>>>>> upstream/main
            if let appConfigs = config.appConfigs {
                if appConfigs.contains(where: { $0.bundleIdentifier == bundleId }) {
                    return config
                }
            }
        }
        return nil
    }
    
<<<<<<< HEAD
    // Add app configuration
=======
    func getDefaultConfiguration() -> PowerModeConfig? {
        return configurations.first { $0.isEnabled && $0.isDefault }
    }
    
    func hasDefaultConfiguration() -> Bool {
        return configurations.contains { $0.isDefault }
    }
    
    func setAsDefault(configId: UUID) {
        // Clear any existing default
        for index in configurations.indices {
            configurations[index].isDefault = false
        }
        
        // Set the specified config as default
        if let index = configurations.firstIndex(where: { $0.id == configId }) {
            configurations[index].isDefault = true
        }
        
        saveConfigurations()
    }
    
    func enableConfiguration(with id: UUID) {
        if let index = configurations.firstIndex(where: { $0.id == id }) {
            configurations[index].isEnabled = true
            saveConfigurations()
        }
    }
    
    func disableConfiguration(with id: UUID) {
        if let index = configurations.firstIndex(where: { $0.id == id }) {
            configurations[index].isEnabled = false
            saveConfigurations()
        }
    }
    
    var enabledConfigurations: [PowerModeConfig] {
        return configurations.filter { $0.isEnabled }
    }

>>>>>>> upstream/main
    func addAppConfig(_ appConfig: AppConfig, to config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            var configs = updatedConfig.appConfigs ?? []
            configs.append(appConfig)
            updatedConfig.appConfigs = configs
            updateConfiguration(updatedConfig)
        }
    }
<<<<<<< HEAD
    
    // Remove app configuration
=======

>>>>>>> upstream/main
    func removeAppConfig(_ appConfig: AppConfig, from config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            updatedConfig.appConfigs?.removeAll(where: { $0.id == appConfig.id })
            updateConfiguration(updatedConfig)
        }
    }
<<<<<<< HEAD
    
    // Add URL configuration
=======

>>>>>>> upstream/main
    func addURLConfig(_ urlConfig: URLConfig, to config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            var configs = updatedConfig.urlConfigs ?? []
            configs.append(urlConfig)
            updatedConfig.urlConfigs = configs
            updateConfiguration(updatedConfig)
        }
    }
<<<<<<< HEAD
    
    // Remove URL configuration
=======

>>>>>>> upstream/main
    func removeURLConfig(_ urlConfig: URLConfig, from config: PowerModeConfig) {
        if var updatedConfig = configurations.first(where: { $0.id == config.id }) {
            updatedConfig.urlConfigs?.removeAll(where: { $0.id == urlConfig.id })
            updateConfiguration(updatedConfig)
        }
    }
<<<<<<< HEAD
    
    // Clean URL for comparison
=======

>>>>>>> upstream/main
    func cleanURL(_ url: String) -> String {
        return url.lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
<<<<<<< HEAD
            .replacingOccurrences(of: NSLocalizedString("www.", comment: "www."), with: "")
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
=======
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func setActiveConfiguration(_ config: PowerModeConfig?) {
        activeConfiguration = config
        UserDefaults.standard.set(config?.id.uuidString, forKey: activeConfigIdKey)
        self.objectWillChange.send()
    }

    var currentActiveConfiguration: PowerModeConfig? {
        return activeConfiguration
    }

    func getAllAvailableConfigurations() -> [PowerModeConfig] {
        return configurations
    }

    func isEmojiInUse(_ emoji: String) -> Bool {
>>>>>>> upstream/main
        return configurations.contains { $0.emoji == emoji }
    }
} 