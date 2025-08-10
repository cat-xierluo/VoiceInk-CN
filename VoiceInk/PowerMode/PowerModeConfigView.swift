import SwiftUI

struct ConfigurationView: View {
    let mode: ConfigurationMode
    let powerModeManager: PowerModeManager
    @EnvironmentObject var enhancementService: AIEnhancementService
    @EnvironmentObject var aiService: AIService
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var isNameFieldFocused: Bool
    
    // State for configuration
    @State private var configName: String = "New Power Mode"
    @State private var selectedEmoji: String = "💼"
    @State private var isShowingEmojiPicker = false
    @State private var isShowingAppPicker = false
    @State private var isAIEnhancementEnabled: Bool
    @State private var selectedPromptId: UUID?
    @State private var selectedTranscriptionModelName: String?
    @State private var selectedLanguage: String?
    @State private var installedApps: [(url: URL, name: String, bundleId: String, icon: NSImage)] = []
    @State private var searchText = ""
    
    // Validation state
    @State private var validationErrors: [PowerModeValidationError] = []
    @State private var showValidationAlert = false
    
    // New state for AI provider and model
    @State private var selectedAIProvider: String?
    @State private var selectedAIModel: String?
    
    // App and Website configurations
    @State private var selectedAppConfigs: [AppConfig] = []
    @State private var websiteConfigs: [URLConfig] = []
    @State private var newWebsiteURL: String = ""
    
    // New state for screen capture toggle
    @State private var useScreenCapture = false
    // NEW: Auto-send toggle state
    @State private var isAutoSendEnabled = false
    
    // State for prompt editing (similar to EnhancementSettingsView)
    @State private var isEditingPrompt = false
    @State private var selectedPromptForEdit: CustomPrompt?
    
    // Whisper state for model selection
    @EnvironmentObject private var whisperState: WhisperState
    
    private var filteredApps: [(url: URL, name: String, bundleId: String, icon: NSImage)] {
        if searchText.isEmpty {
            return installedApps
        }
        return installedApps.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText) ||
            app.bundleId.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // Simplified computed property for effective model name
    private var effectiveModelName: String? {
        if let model = selectedTranscriptionModelName {
            return model
        }
        return whisperState.currentTranscriptionModel?.name
    }
    
    init(mode: ConfigurationMode, powerModeManager: PowerModeManager) {
        self.mode = mode
        self.powerModeManager = powerModeManager
        
        // Always fetch the most current configuration data
        switch mode {
        case .add:
            _isAIEnhancementEnabled = State(initialValue: true)
            _selectedPromptId = State(initialValue: nil)
            _selectedTranscriptionModelName = State(initialValue: nil)
            _selectedLanguage = State(initialValue: nil)
            _configName = State(initialValue: "")
            _selectedEmoji = State(initialValue: "✏️")
            _useScreenCapture = State(initialValue: false)
            _isAutoSendEnabled = State(initialValue: false)
            // Default to current global AI provider/model for new configurations - use UserDefaults only
            _selectedAIProvider = State(initialValue: UserDefaults.standard.string(forKey: "selectedAIProvider"))
            _selectedAIModel = State(initialValue: nil) // Initialize to nil and set it after view appears
        case .edit(let config):
            // Get the latest version of this config from PowerModeManager
            let latestConfig = powerModeManager.getConfiguration(with: config.id) ?? config
            _isAIEnhancementEnabled = State(initialValue: latestConfig.isAIEnhancementEnabled)
            _selectedPromptId = State(initialValue: latestConfig.selectedPrompt.flatMap { UUID(uuidString: $0) })
            _selectedTranscriptionModelName = State(initialValue: latestConfig.selectedTranscriptionModelName)
            _selectedLanguage = State(initialValue: latestConfig.selectedLanguage)
            _configName = State(initialValue: latestConfig.name)
            _selectedEmoji = State(initialValue: latestConfig.emoji)
            _selectedAppConfigs = State(initialValue: latestConfig.appConfigs ?? [])
            _websiteConfigs = State(initialValue: latestConfig.urlConfigs ?? [])
            _useScreenCapture = State(initialValue: latestConfig.useScreenCapture)
            _isAutoSendEnabled = State(initialValue: latestConfig.isAutoSendEnabled)
            _selectedAIProvider = State(initialValue: latestConfig.selectedAIProvider)
            _selectedAIModel = State(initialValue: latestConfig.selectedAIModel)
        case .editDefault(let config):
            // Always use the latest default config
            let latestConfig = powerModeManager.defaultConfig
            _isAIEnhancementEnabled = State(initialValue: latestConfig.isAIEnhancementEnabled)
            _selectedPromptId = State(initialValue: latestConfig.selectedPrompt.flatMap { UUID(uuidString: $0) })
            _selectedTranscriptionModelName = State(initialValue: latestConfig.selectedTranscriptionModelName)
            _selectedLanguage = State(initialValue: latestConfig.selectedLanguage)
            _configName = State(initialValue: latestConfig.name)
            _selectedEmoji = State(initialValue: latestConfig.emoji)
            _useScreenCapture = State(initialValue: latestConfig.useScreenCapture)
            _isAutoSendEnabled = State(initialValue: latestConfig.isAutoSendEnabled)
            _selectedAIProvider = State(initialValue: latestConfig.selectedAIProvider)
            _selectedAIModel = State(initialValue: latestConfig.selectedAIModel)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Title and Cancel button
            HStack {
                Text(mode.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                if case .edit(let config) = mode {
                    Button("Delete") {
                        powerModeManager.removeConfiguration(with: config.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                    .padding(.trailing, 8)
                }
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Main Input Section
                    HStack(spacing: 16) {
                        Button(action: {
                            isShowingEmojiPicker.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                
                                Text(selectedEmoji)
                                    .font(.system(size: 24))
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(mode.isEditingDefault)
                        .opacity(mode.isEditingDefault ? 0.5 : 1)
                        .popover(isPresented: $isShowingEmojiPicker, arrowEdge: .bottom) {
                            EmojiPickerView(
                                selectedEmoji: $selectedEmoji,
                                isPresented: $isShowingEmojiPicker
                            )
                        }
                        
                        TextField("Name your power mode", text: $configName)
                            .font(.system(size: 18, weight: .bold))
                            .textFieldStyle(.plain)
                            .foregroundColor(.primary)
                            .tint(.accentColor)
                            .disabled(mode.isEditingDefault)
                            .focused($isNameFieldFocused)
                            .onAppear {
                                if !mode.isEditingDefault {
                                    isNameFieldFocused = true
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(CardBackground(isSelected: false))
                    .padding(.horizontal)
                    
                    // Enhanced Emoji Picker with Custom Emoji Support
                    // if isShowingEmojiPicker { // <<< This conditional block will be removed
                    //     EmojiPickerView(
                    //         selectedEmoji: $selectedEmoji,
                    //         isPresented: $isShowingEmojiPicker
                    //     )
                    //     .padding(.horizontal)
                    // }
                    
                    // SECTION 1: TRIGGERS
                    if !mode.isEditingDefault {
                        VStack(spacing: 16) {
                            // Section Header
                            SectionHeader(title: "When to Trigger")
                            
                            // Applications Subsection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Applications")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        loadInstalledApps()
                                        isShowingAppPicker = true
                                    }) {
                                        Label("Add App", systemImage: "plus.circle.fill")
                                            .font(.subheadline)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                if selectedAppConfigs.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("No applications added")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(CardBackground(isSelected: false))
                                } else {
                                    // Grid of selected apps that wraps to next line
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50, maximum: 55), spacing: 10)], spacing: 10) {
                                        ForEach(selectedAppConfigs) { appConfig in
                                            VStack {
                                                ZStack(alignment: .topTrailing) {
                                                    // App icon - completely filling the container
                                                    if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appConfig.bundleIdentifier) {
                                                        Image(nsImage: NSWorkspace.shared.icon(forFile: appURL.path))
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 50, height: 50)
                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    } else {
                                                        Image(systemName: "app.fill")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 50, height: 50)
                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    }
                                                    
                                                    // Remove button
                                                    Button(action: {
                                                        selectedAppConfigs.removeAll(where: { $0.id == appConfig.id })
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.white)
                                                            .background(Circle().fill(Color.black.opacity(0.6)))
                                                    }
                                                    .buttonStyle(.plain)
                                                    .offset(x: 6, y: -6)
                                                }
                                            }
                                            .frame(width: 50, height: 50)
                                            .background(CardBackground(isSelected: false, cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Websites Subsection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Websites")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    
                                // Add URL Field
                                HStack {
                                    TextField("Enter website URL (e.g., google.com)", text: $newWebsiteURL)
                                    .textFieldStyle(.roundedBorder)
                                        .onSubmit {
                                            addWebsite()
                                        }
                                    
                                    Button(action: addWebsite) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.accentColor)
                                            .font(.system(size: 18))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(newWebsiteURL.isEmpty)
                                }
                                
                                if websiteConfigs.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("No websites added")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(CardBackground(isSelected: false))
                                } else {
                                    // Grid of website tags that wraps to next line
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 10)], spacing: 10) {
                                        ForEach(websiteConfigs) { urlConfig in
                                            HStack(spacing: 4) {
                                                Image(systemName: "globe")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.accentColor)
                                                
                                                Text(urlConfig.url)
                                                    .font(.system(size: 11))
                                                    .lineLimit(1)
                                                
                                                Spacer(minLength: 0)
                                                
                                                Button(action: {
                                                    websiteConfigs.removeAll(where: { $0.id == urlConfig.id })
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 9))
                                                        .foregroundColor(.secondary)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 6)
                                            .frame(height: 28)
                                            .background(CardBackground(isSelected: false, cornerRadius: 10))
                                        }
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .padding()
                        .background(CardBackground(isSelected: false))
                        .padding(.horizontal)
                    }
                    
                    // SECTION 2: TRANSCRIPTION
                    VStack(spacing: 16) {
                        // Section Header
                        SectionHeader(title: "Transcription")
                        
                        // Whisper Model Selection Subsection
                        if whisperState.usableModels.isEmpty {
                            Text("No transcription models available. Please connect to a cloud service or download a local model in the AI Models tab.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(CardBackground(isSelected: false))
                        } else {
                            // Create a simple binding that uses current model if nil
                            let modelBinding = Binding<String?>(
                                get: {
                                    selectedTranscriptionModelName ?? whisperState.usableModels.first?.name
                                },
                                set: { selectedTranscriptionModelName = $0 }
                            )
                            
                            HStack {
                                Text("Model")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("", selection: modelBinding) {
                                    ForEach(whisperState.usableModels, id: \.name) { model in
                                        Text(model.displayName).tag(model.name as String?)
                                    }
                                }
                                .labelsHidden()

                                Spacer()
                            }
                        }
                        
                        // Language Selection Subsection
                        if let selectedModel = effectiveModelName,
                           let modelInfo = whisperState.allAvailableModels.first(where: { $0.name == selectedModel }),
                           modelInfo.isMultilingualModel {
                            
                            // Create a simple binding that uses UserDefaults language if nil
                            let languageBinding = Binding<String?>(
                                get: {
                                    selectedLanguage ?? UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "auto"
                                },
                                set: { selectedLanguage = $0 }
                            )
                            
                            HStack {
                                Text("Language")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Picker("", selection: languageBinding) {
                                    ForEach(modelInfo.supportedLanguages.sorted(by: { 
                                        if $0.key == "auto" { return true }
                                        if $1.key == "auto" { return false }
                                        return $0.value < $1.value
                                    }), id: \.key) { key, value in
                                        Text(value).tag(key as String?)
                                    }
                                }
                                .labelsHidden()

                                Spacer()
                            }
                        } else if let selectedModel = effectiveModelName,
                                  let modelInfo = whisperState.allAvailableModels.first(where: { $0.name == selectedModel }),
                                  !modelInfo.isMultilingualModel {
                            // Silently set to English without showing UI
                            let _ = { selectedLanguage = "en" }()
                        }
                    }
                    .padding()
                    .background(CardBackground(isSelected: false))
                    .padding(.horizontal)
                    
                    // SECTION 3: AI ENHANCEMENT
                    VStack(spacing: 16) {
                        // Section Header
                        SectionHeader(title: "AI Enhancement")

                        Toggle("Enable AI Enhancement", isOn: $isAIEnhancementEnabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onChange(of: isAIEnhancementEnabled) { oldValue, newValue in
                                if newValue {
                                    // When enabling AI enhancement, set default values if none are selected
                                    if selectedAIProvider == nil {
                                        selectedAIProvider = aiService.selectedProvider.rawValue
                                    }
                                    if selectedAIModel == nil {
                                        selectedAIModel = aiService.currentModel
                                    }
                                }
                            }

                        Divider()
                            
                            // AI Provider Selection - Match style with Whisper model selection
                            // Create a binding for the provider selection that falls back to global settings
                            let providerBinding = Binding<AIProvider>(
                                get: {
                                    if let providerName = selectedAIProvider,
                                       let provider = AIProvider(rawValue: providerName) {
                                        return provider
                                    }
                                    // Just return the global provider without modifying state
                                    return aiService.selectedProvider
                                },
                                set: { newValue in
                                    selectedAIProvider = newValue.rawValue // Update local state for UI responsiveness
                                    aiService.selectedProvider = newValue // Update global AI service state
                                    selectedAIModel = nil                 // Reset selected model when provider changes
                                }
                            )
                            
                            
                        
                        
                        if isAIEnhancementEnabled {
                            
                            HStack {
                                Text("AI Provider")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if aiService.connectedProviders.isEmpty {
                                    Text("No providers connected")
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Picker("", selection: providerBinding) {
                                        ForEach(aiService.connectedProviders.filter { $0 != .elevenLabs && $0 != .deepgram }, id: \.self) { provider in
                                            Text(provider.rawValue).tag(provider)
                                        }
                                    }
                                    .labelsHidden()
                                    .onChange(of: selectedAIProvider) { oldValue, newValue in
                                        // When provider changes, ensure we have a valid model for that provider
                                        if let provider = newValue.flatMap({ AIProvider(rawValue: $0) }) {
                                            // Set default model for this provider
                                            selectedAIModel = provider.defaultModel
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            
                            // AI Model Selection - Match style with whisper language selection
                            let providerName = selectedAIProvider ?? aiService.selectedProvider.rawValue
                            if let provider = AIProvider(rawValue: providerName),
                               provider != .custom {
                                
                                HStack {
                                    Text("AI Model")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if aiService.availableModels.isEmpty {
                                        Text(provider == .openRouter ? "No models loaded" : "No models available")
                                            .foregroundColor(.secondary)
                                            .italic()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        // Create binding that falls back to current model for the selected provider
                                        let modelBinding = Binding<String>(
                                            get: { 
                                                if let model = selectedAIModel, !model.isEmpty {
                                                    return model
                                                }
                                                // Just return the current model without modifying state
                                                return aiService.currentModel
                                            },
                                            set: { newModelValue in
                                                selectedAIModel = newModelValue // Update local state
                                                // Update the model in AIService for the current provider
                                                aiService.selectModel(newModelValue)
                                            }
                                        )
                                        
                                        let models = provider == .openRouter ? aiService.availableModels : (provider == .ollama ? aiService.availableModels : provider.availableModels)
                                        
                                        Picker("", selection: modelBinding) {
                                            ForEach(models, id: \.self) { model in
                                                Text(model).tag(model)
                                            }
                                        }
                                        .labelsHidden()
                                        
                                        if provider == .openRouter {
                                            Button(action: {
                                                Task {
                                                    await aiService.fetchOpenRouterModels()
                                                }
                                            }) {
                                                Image(systemName: "arrow.clockwise")
                                            }
                                            .buttonStyle(.borderless)
                                            .help("Refresh models")
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        
                            
                            // Enhancement Prompts Section (reused from EnhancementSettingsView)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Enhancement Prompt")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                PromptSelectionGrid(
                                    prompts: enhancementService.allPrompts,
                                    selectedPromptId: selectedPromptId,
                                    onPromptSelected: { prompt in
                                        selectedPromptId = prompt.id
                                    },
                                    onEditPrompt: { prompt in
                                        selectedPromptForEdit = prompt
                                    },
                                    onDeletePrompt: { prompt in
                                        enhancementService.deletePrompt(prompt)
                                    },
                                    onAddNewPrompt: {
                                        isEditingPrompt = true
                                    }
                                )
                            }

                            Divider()
                            
                           
                            Toggle("Context Awareness", isOn: $useScreenCapture)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            
                        }
                    }
                    .padding()
                    .background(CardBackground(isSelected: false))
                    .padding(.horizontal)
                    
                    // SECTION 4: ADVANCED
                    VStack(spacing: 16) {
                        SectionHeader(title: "Advanced")

                        HStack {
                            Toggle("Auto Send", isOn: $isAutoSendEnabled)
                            
                            InfoTip(
                                title: "Auto Send",
                                message: "Automatically presses the Return/Enter key after pasting text. This is useful for chat applications or forms where its not necessary to to make changes to the transcribed text"
                            )
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(CardBackground(isSelected: false))
                    .padding(.horizontal)
                    
                    // Save Button
                    VoiceInkButton(
                        title: mode.isAdding ? "Add New Power Mode" : "Save Changes",
                        action: saveConfiguration,
                        isDisabled: !canSave
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $isShowingAppPicker) {
            AppPickerSheet(
                installedApps: filteredApps,
                selectedAppConfigs: $selectedAppConfigs,
                searchText: $searchText,
                onDismiss: { isShowingAppPicker = false }
            )
        }
        .sheet(isPresented: $isEditingPrompt) {
            PromptEditorView(mode: .add)
        }
        .sheet(item: $selectedPromptForEdit) { prompt in
            PromptEditorView(mode: .edit(prompt))
        }
        .powerModeValidationAlert(errors: validationErrors, isPresented: $showValidationAlert)
        .navigationTitle("") // Explicitly set an empty title for this view
        .toolbar(.hidden) // Attempt to hide the navigation bar area
        .onAppear {
            // Set AI provider and model for new power modes after environment objects are available
            if case .add = mode {
                if selectedAIProvider == nil {
                    selectedAIProvider = aiService.selectedProvider.rawValue
                }
                if selectedAIModel == nil || selectedAIModel?.isEmpty == true {
                    selectedAIModel = aiService.currentModel
                }
            }
            
            // Select first prompt if AI enhancement is enabled and no prompt is selected
            if isAIEnhancementEnabled && selectedPromptId == nil {
                selectedPromptId = enhancementService.allPrompts.first?.id
            }
        }
    }
    
    private var canSave: Bool {
        return !configName.isEmpty
    }
    
    private func addWebsite() {
        guard !newWebsiteURL.isEmpty else { return }
        
        let cleanedURL = powerModeManager.cleanURL(newWebsiteURL)
        let urlConfig = URLConfig(url: cleanedURL)
        websiteConfigs.append(urlConfig)
        newWebsiteURL = ""
    }
    
    private func toggleAppSelection(_ app: (url: URL, name: String, bundleId: String, icon: NSImage)) {
        if let index = selectedAppConfigs.firstIndex(where: { $0.bundleIdentifier == app.bundleId }) {
            selectedAppConfigs.remove(at: index)
        } else {
            let appConfig = AppConfig(bundleIdentifier: app.bundleId, appName: app.name)
            selectedAppConfigs.append(appConfig)
        }
    }
    
    private func getConfigForForm() -> PowerModeConfig {
        switch mode {
        case .add:
                return PowerModeConfig(
                name: configName,
                emoji: selectedEmoji,
                appConfigs: selectedAppConfigs.isEmpty ? nil : selectedAppConfigs,
                urlConfigs: websiteConfigs.isEmpty ? nil : websiteConfigs,
                    isAIEnhancementEnabled: isAIEnhancementEnabled,
                    selectedPrompt: selectedPromptId?.uuidString,
                    selectedTranscriptionModelName: selectedTranscriptionModelName,
                    selectedLanguage: selectedLanguage,
                    useScreenCapture: useScreenCapture,
                    selectedAIProvider: selectedAIProvider,
                    selectedAIModel: selectedAIModel,
                    isAutoSendEnabled: isAutoSendEnabled
                )
        case .edit(let config):
            var updatedConfig = config
            updatedConfig.name = configName
            updatedConfig.emoji = selectedEmoji
            updatedConfig.isAIEnhancementEnabled = isAIEnhancementEnabled
            updatedConfig.selectedPrompt = selectedPromptId?.uuidString
            updatedConfig.selectedTranscriptionModelName = selectedTranscriptionModelName
            updatedConfig.selectedLanguage = selectedLanguage
            updatedConfig.appConfigs = selectedAppConfigs.isEmpty ? nil : selectedAppConfigs
            updatedConfig.urlConfigs = websiteConfigs.isEmpty ? nil : websiteConfigs
            updatedConfig.useScreenCapture = useScreenCapture
            updatedConfig.isAutoSendEnabled = isAutoSendEnabled
            updatedConfig.selectedAIProvider = selectedAIProvider
            updatedConfig.selectedAIModel = selectedAIModel
            return updatedConfig
            
        case .editDefault(let config):
            var updatedConfig = config
            updatedConfig.name = configName
            updatedConfig.emoji = selectedEmoji
            updatedConfig.isAIEnhancementEnabled = isAIEnhancementEnabled
            updatedConfig.selectedPrompt = selectedPromptId?.uuidString
            updatedConfig.selectedTranscriptionModelName = selectedTranscriptionModelName
            updatedConfig.selectedLanguage = selectedLanguage
            updatedConfig.useScreenCapture = useScreenCapture
            updatedConfig.isAutoSendEnabled = isAutoSendEnabled
            updatedConfig.selectedAIProvider = selectedAIProvider
            updatedConfig.selectedAIModel = selectedAIModel
            return updatedConfig
        }
    }
    
    private func loadInstalledApps() {
        // Get both user-installed and system applications
        let userAppURLs = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
        let localAppURLs = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask)
        let systemAppURLs = FileManager.default.urls(for: .applicationDirectory, in: .systemDomainMask)
        let allAppURLs = userAppURLs + localAppURLs + systemAppURLs
        
        let apps = allAppURLs.flatMap { baseURL -> [URL] in
            let enumerator = FileManager.default.enumerator(
                at: baseURL,
                includingPropertiesForKeys: [.isApplicationKey, .isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            
            return enumerator?.compactMap { item -> URL? in
                guard let url = item as? URL else { return nil }
                
                // If it's an app, return it and skip descending into it
                if url.pathExtension == "app" {
                    enumerator?.skipDescendants()
                    return url
                }
                
                // Continue searching in directories
                return nil
            } ?? []
        }
        
        installedApps = apps.compactMap { url in
            guard let bundle = Bundle(url: url),
                  let bundleId = bundle.bundleIdentifier,
                  let name = (bundle.infoDictionary?["CFBundleName"] as? String) ??
                            (bundle.infoDictionary?["CFBundleDisplayName"] as? String) else {
                return nil
            }
            
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            return (url: url, name: name, bundleId: bundleId, icon: icon)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    private func saveConfiguration() {
        
        
        let config = getConfigForForm()
        
        // Only validate when the user explicitly tries to save
        let validator = PowerModeValidator(powerModeManager: powerModeManager)
        validationErrors = validator.validateForSave(config: config, mode: mode)
        
        if !validationErrors.isEmpty {
            showValidationAlert = true
            return
        }
        
        // If validation passes, save the configuration
        switch mode {
        case .add:
            powerModeManager.addConfiguration(config)
        case .edit, .editDefault:
            powerModeManager.updateConfiguration(config)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
