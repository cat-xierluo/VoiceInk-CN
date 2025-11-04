import SwiftUI

struct APIKeyManagementView: View {
    @EnvironmentObject private var aiService: AIService
    @State private var apiKey: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isVerifying = false
    @State private var ollamaBaseURL: String = UserDefaults.standard.string(forKey: "ollamaBaseURL") ?? "http://localhost:11434"
    @State private var ollamaModels: [OllamaService.OllamaModel] = []
    @State private var selectedOllamaModel: String = UserDefaults.standard.string(forKey: "ollamaSelectedModel") ?? "mistral"
    @State private var isCheckingOllama = false
    @State private var isEditingURL = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
<<<<<<< HEAD
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
Text(NSLocalizedString("Enhance your transcriptions with AI", comment: "Enhance your transcriptions with AI"))
                        .font(.headline)
                        .foregroundColor(.secondary)
=======
            // Provider Selection
            HStack {
                Picker("AI Provider", selection: $aiService.selectedProvider) {
                    ForEach(AIProvider.allCases.filter { $0 != .elevenLabs && $0 != .deepgram && $0 != .soniox }, id: \.self) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
>>>>>>> upstream/main
                }
                
                Spacer()
                
                if aiService.isAPIKeyValid && aiService.selectedProvider != .ollama {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
<<<<<<< HEAD
                        Text(NSLocalizedString("Connected to", comment: "Connected to"))
=======
                        Text("Connected to")
>>>>>>> upstream/main
                            .font(.caption)
                        Text(aiService.selectedProvider.rawValue)
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.secondary)
                    .cornerRadius(6)
                }
            }
            
<<<<<<< HEAD
            // Provider Selection
Picker(NSLocalizedString("AI Provider", comment: "AI Provider"), selection: $aiService.selectedProvider) {
                ForEach(AIProvider.allCases.filter { $0 != .elevenLabs && $0 != .deepgram }, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            
=======
>>>>>>> upstream/main
            .onChange(of: aiService.selectedProvider) { oldValue, newValue in
                if aiService.selectedProvider == .ollama {
                    checkOllamaConnection()
                }
            }
            
            // Model Selection
            if aiService.selectedProvider == .openRouter {
                HStack {
                    if aiService.availableModels.isEmpty {
<<<<<<< HEAD
Text(NSLocalizedString("No models loaded", comment: "No models loaded"))
                            .foregroundColor(.secondary)
                    } else {
Picker(NSLocalizedString("Model", comment: "Model"), selection: Binding(
=======
                        Text("No models loaded")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Model", selection: Binding(
>>>>>>> upstream/main
                            get: { aiService.currentModel },
                            set: { aiService.selectModel($0) }
                        )) {
                            ForEach(aiService.availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                    }
                    
                    
                    
                    Button(action: {
                        Task {
                            await aiService.fetchOpenRouterModels()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
<<<<<<< HEAD
                    .help(NSLocalizedString("Refresh models", comment: "Refresh models"))
=======
                    .help("Refresh models")
>>>>>>> upstream/main
                }
            } else if !aiService.availableModels.isEmpty && 
                        aiService.selectedProvider != .ollama && 
                        aiService.selectedProvider != .custom {
                HStack {
<<<<<<< HEAD
Picker(NSLocalizedString("Model", comment: "Model"), selection: Binding(
=======
                    Picker("Model", selection: Binding(
>>>>>>> upstream/main
                        get: { aiService.currentModel },
                        set: { aiService.selectModel($0) }
                    )) {
                        ForEach(aiService.availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
            }
            
            if aiService.selectedProvider == .ollama {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with status
                    HStack {
<<<<<<< HEAD
                        Label(NSLocalizedString("Ollama Configuration", comment: "Ollama Configuration"), systemImage: "server.rack")
=======
                        Label("Ollama Configuration", systemImage: "server.rack")
>>>>>>> upstream/main
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isCheckingOllama ? Color.orange : (ollamaModels.isEmpty ? Color.red : Color.green))
                                .frame(width: 8, height: 8)
<<<<<<< HEAD
Text(isCheckingOllama ? "Checking..." : (ollamaModels.isEmpty ? "Disconnected" : NSLocalizedString("Connected", comment: "Connected")))
=======
                            Text(isCheckingOllama ? "Checking..." : (ollamaModels.isEmpty ? "Disconnected" : "Connected"))
>>>>>>> upstream/main
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    // Server URL
                    HStack {
                        Label("Server URL", systemImage: "link")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if isEditingURL {
<<<<<<< HEAD
                            TextField(NSLocalizedString("Base URL", comment: "Base URL"), text: $ollamaBaseURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 200)
                            
                            Button(NSLocalizedString("Save", comment: "Save button")) {
=======
                            TextField("Base URL", text: $ollamaBaseURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 200)
                            
                            Button("Save") {
>>>>>>> upstream/main
                                aiService.updateOllamaBaseURL(ollamaBaseURL)
                                checkOllamaConnection()
                                isEditingURL = false
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        } else {
                            Text(ollamaBaseURL)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                            
                            Button(action: { isEditingURL = true }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            .controlSize(.small)
                            
                            Button(action: {
                                ollamaBaseURL = "http://localhost:11434"
                                aiService.updateOllamaBaseURL(ollamaBaseURL)
                                checkOllamaConnection()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.secondary)
                            .controlSize(.small)
                        }
                    }
                    
                    // Model selection and refresh
                    HStack {
<<<<<<< HEAD
Label(NSLocalizedString("Model", comment: "Model"), systemImage: "cpu")
=======
                        Label("Model", systemImage: "cpu")
>>>>>>> upstream/main
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if ollamaModels.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
<<<<<<< HEAD
Text(NSLocalizedString("No models available", comment: "No models available"))
=======
                                Text("No models available")
>>>>>>> upstream/main
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        } else {
                            Picker("", selection: $selectedOllamaModel) {
                                ForEach(ollamaModels) { model in
                                    Text(model.name).tag(model.name)
                                }
                            }
                            .onChange(of: selectedOllamaModel) { oldValue, newValue in
                                aiService.updateSelectedOllamaModel(newValue)
                            }
                            .labelsHidden()
                            .frame(maxWidth: 150)
                        }
                        
                        Button(action: { checkOllamaConnection() }) {
<<<<<<< HEAD
Label(isCheckingOllama ? "Refreshing..." : NSLocalizedString("Refresh", comment: "Refresh"), systemImage: isCheckingOllama ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
=======
                            Label(isCheckingOllama ? "Refreshing..." : "Refresh", systemImage: isCheckingOllama ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
>>>>>>> upstream/main
                                .font(.caption)
                        }
                        .disabled(isCheckingOllama)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    // Help text for troubleshooting
                    if ollamaModels.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
                            Text(NSLocalizedString("Troubleshooting", comment: "Troubleshooting"))
=======
                            Text("Troubleshooting")
>>>>>>> upstream/main
                                .font(.subheadline)
                                .bold()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                bulletPoint("Ensure Ollama is installed and running")
                                bulletPoint("Check if the server URL is correct")
                                bulletPoint("Verify you have at least one model pulled")
                            }
                            
<<<<<<< HEAD
                            Button(NSLocalizedString("Learn More", comment: "Learn More")) {
=======
                            Button("Learn More") {
>>>>>>> upstream/main
                                NSWorkspace.shared.open(URL(string: "https://ollama.ai/download")!)
                            }
                            .font(.caption)
                        }
                        .padding(12)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.03))
                .cornerRadius(12)

            } else if aiService.selectedProvider == .custom {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Provider Configuration")
                            .font(.headline)
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Requires OpenAI-compatible API endpoint")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Configuration Fields
                    VStack(alignment: .leading, spacing: 8) {
                        if !aiService.isAPIKeyValid {
<<<<<<< HEAD
                            TextField(NSLocalizedString("API Endpoint URL (e.g., https://api.example.com/v1/chat/completions)", comment: "API Endpoint URL placeholder"), text: $aiService.customBaseURL)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField(NSLocalizedString("Model Name (e.g., gpt-4o-mini, claude-3-5-sonnet-20240620)", comment: "Model Name placeholder"), text: $aiService.customModel)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("API Endpoint URL", comment: "API Endpoint URL"))
=======
                            TextField("API Endpoint URL (e.g., https://api.example.com/v1/chat/completions)", text: $aiService.customBaseURL)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Model Name (e.g., gpt-4o-mini, claude-3-5-sonnet-20240620)", text: $aiService.customModel)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("API Endpoint URL")
>>>>>>> upstream/main
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(aiService.customBaseURL)
                                    .font(.system(.body, design: .monospaced))
                                
<<<<<<< HEAD
Text(NSLocalizedString("Model", comment: "Model"))
=======
                                Text("Model")
>>>>>>> upstream/main
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(aiService.customModel)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        
                        if aiService.isAPIKeyValid {
<<<<<<< HEAD
Text(NSLocalizedString("API Key", comment: "API Key"))
=======
                            Text("API Key")
>>>>>>> upstream/main
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(String(repeating: "•", count: 40))
                                    .font(.system(.body, design: .monospaced))
                                
                                Spacer()
                                
                                Button(action: {
                                    aiService.clearAPIKey()
                                }) {
<<<<<<< HEAD
                                    Label(NSLocalizedString(NSLocalizedString("Remove Key", comment: "Remove Key"), comment: "Remove Key"), systemImage: "trash")
=======
                                    Label("Remove Key", systemImage: "trash")
>>>>>>> upstream/main
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                        } else {
<<<<<<< HEAD
Text(NSLocalizedString("Enter your API Key", comment: "Enter your API Key"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
SecureField(NSLocalizedString("API Key", comment: "API Key"), text: $apiKey)
=======
                            Text("Enter your API Key")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("API Key", text: $apiKey)
>>>>>>> upstream/main
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                            
                            HStack {
                                Button(action: {
                                    isVerifying = true
                                    aiService.saveAPIKey(apiKey) { success in
                                        isVerifying = false
                                        if !success {
                                            alertMessage = "Invalid API key. Please check and try again."
                                            showAlert = true
                                        }
                                        apiKey = ""
                                    }
                                }) {
                                    HStack {
                                        if isVerifying {
                                            ProgressView()
                                                .scaleEffect(0.5)
                                                .frame(width: 16, height: 16)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
<<<<<<< HEAD
Text(NSLocalizedString("Verify and Save", comment: "Verify and Save"))
=======
                                        Text("Verify and Save")
>>>>>>> upstream/main
                                    }
                                }
                                .disabled(aiService.customBaseURL.isEmpty || aiService.customModel.isEmpty || apiKey.isEmpty)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.03))
                .cornerRadius(12)
            } else {
                // API Key Display for other providers if valid
                if aiService.isAPIKeyValid {
                    VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("API Key", comment: "API Key"))
=======
                        Text("API Key")
>>>>>>> upstream/main
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(String(repeating: "•", count: 40))
                                .font(.system(.body, design: .monospaced))
                            
                            Spacer()
                            
                            Button(action: {
                                aiService.clearAPIKey()
                            }) {
                                Label("Remove Key", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                } else {
                    // API Key Input for other providers
                    VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("Enter your API Key", comment: "Enter your API Key"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
SecureField(NSLocalizedString("API Key", comment: "API Key"), text: $apiKey)
=======
                        Text("Enter your API Key")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        SecureField("API Key", text: $apiKey)
>>>>>>> upstream/main
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                        
                        HStack {
                            Button(action: {
                                isVerifying = true
                                aiService.saveAPIKey(apiKey) { success in
                                    isVerifying = false
                                    if !success {
                                        alertMessage = "Invalid API key. Please check and try again."
                                        showAlert = true
                                    }
                                    apiKey = ""
                                }
                            }) {
                                HStack {
                                    if isVerifying {
                                        ProgressView()
                                            .scaleEffect(0.5)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
<<<<<<< HEAD
Text(NSLocalizedString("Verify and Save", comment: "Verify and Save"))
=======
                                    Text("Verify and Save")
>>>>>>> upstream/main
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
<<<<<<< HEAD
Text((aiService.selectedProvider == .groq || aiService.selectedProvider == .gemini || aiService.selectedProvider == .cerebras) ? NSLocalizedString("Free", comment: "Free") : "Paid")
=======
                                Text((aiService.selectedProvider == .groq || aiService.selectedProvider == .gemini || aiService.selectedProvider == .cerebras) ? "Free" : "Paid")
>>>>>>> upstream/main
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(4)
                                
                                if aiService.selectedProvider != .ollama && aiService.selectedProvider != .custom {
                                    Button {
                                        let url = switch aiService.selectedProvider {
                                        case .groq:
                                            URL(string: "https://console.groq.com/keys")!
                                        case .openAI:
                                            URL(string: "https://platform.openai.com/api-keys")!
                                        case .gemini:
                                            URL(string: "https://makersuite.google.com/app/apikey")!
                                        case .anthropic:
                                            URL(string: "https://console.anthropic.com/settings/keys")!
                                        case .mistral:
                                            URL(string: "https://console.mistral.ai/api-keys")!
                                        case .elevenLabs:
                                            URL(string: "https://elevenlabs.io/speech-synthesis")!
                                        case .deepgram:
                                            URL(string: "https://console.deepgram.com/api-keys")!
<<<<<<< HEAD
=======
                                            case .soniox:
                                                URL(string: "https://console.soniox.com/")!
>>>>>>> upstream/main
                                        case .ollama, .custom:
                                            URL(string: "")! // This case should never be reached
                                        case .openRouter:
                                            URL(string: "https://openrouter.ai/keys")!
                                        case .cerebras:
                                            URL(string: "https://cloud.cerebras.ai/")!
                                        }
                                        NSWorkspace.shared.open(url)
                                    } label: {
                                        HStack(spacing: 4) {
<<<<<<< HEAD
Text(NSLocalizedString("Get API Key", comment: "Get API Key"))
=======
                                            Text("Get API Key")
>>>>>>> upstream/main
                                                .foregroundColor(.accentColor)
                                            Image(systemName: "arrow.up.right")
                                                .font(.caption)
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
<<<<<<< HEAD
        .padding()
.alert(NSLocalizedString("Error", comment: "Error"), isPresented: $showAlert) {
                                Button(NSLocalizedString("OK", comment: "OK"), role: .cancel) { }
=======
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
>>>>>>> upstream/main
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            if aiService.selectedProvider == .ollama {
                checkOllamaConnection()
            }
        }
    }
    
    private func checkOllamaConnection() {
        isCheckingOllama = true
        aiService.checkOllamaConnection { connected in
            if connected {
                Task {
                    ollamaModels = await aiService.fetchOllamaModels()
                    isCheckingOllama = false
                }
            } else {
                ollamaModels = []
                isCheckingOllama = false
                alertMessage = "Could not connect to Ollama. Please check if Ollama is running and the base URL is correct."
                showAlert = true
            }
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text("•")
            Text(text)
        }
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        let gigabytes = Double(bytes) / 1_000_000_000
        return String(format: "%.1f GB", gigabytes)
    }
}
