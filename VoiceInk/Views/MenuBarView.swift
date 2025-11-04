import SwiftUI
import LaunchAtLogin

struct MenuBarView: View {
    @EnvironmentObject var whisperState: WhisperState
    @EnvironmentObject var hotkeyManager: HotkeyManager
    @EnvironmentObject var menuBarManager: MenuBarManager
    @EnvironmentObject var updaterViewModel: UpdaterViewModel
    @EnvironmentObject var enhancementService: AIEnhancementService
    @EnvironmentObject var aiService: AIService
    @State private var launchAtLoginEnabled = LaunchAtLogin.isEnabled
    @State private var menuRefreshTrigger = false  // Added to force menu updates
    @State private var isHovered = false
    
    var body: some View {
        VStack {
<<<<<<< HEAD
Button(NSLocalizedString("Toggle Mini Recorder", comment: "Toggle Mini Recorder")) {
                Task {
                    await whisperState.toggleMiniRecorder()
                }
            }
            
Toggle(NSLocalizedString("AI Enhancement", comment: "AI Enhancement"), isOn: $enhancementService.isEnhancementEnabled)
=======
            Menu {
                ForEach(whisperState.usableModels, id: \.id) { model in
                    Button {
                        Task {
                            await whisperState.setDefaultTranscriptionModel(model)
                        }
                    } label: {
                        HStack {
                            Text(model.displayName)
                            if whisperState.currentTranscriptionModel?.id == model.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                Button("Manage Models") {
                    menuBarManager.openMainWindowAndNavigate(to: "AI Models")
                }
            } label: {
                HStack {
                    Text("Transcription Model: \(whisperState.currentTranscriptionModel?.displayName ?? "None")")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
            Divider()
            
            Toggle("AI Enhancement", isOn: $enhancementService.isEnhancementEnabled)
>>>>>>> upstream/main
            
            Menu {
                ForEach(enhancementService.allPrompts) { prompt in
                    Button {
                        enhancementService.setActivePrompt(prompt)
                    } label: {
                        HStack {
<<<<<<< HEAD
                            Image(systemName: prompt.icon.rawValue)
=======
                            Image(systemName: prompt.icon)
>>>>>>> upstream/main
                                .foregroundColor(.accentColor)
                            Text(prompt.title)
                            if enhancementService.selectedPromptId == prompt.id {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
<<<<<<< HEAD
Text("Prompt: \(enhancementService.activePrompt?.title ?? NSLocalizedString("None", comment: "None"))")
=======
                    Text("Prompt: \(enhancementService.activePrompt?.title ?? "None")")
>>>>>>> upstream/main
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            .disabled(!enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(aiService.connectedProviders, id: \.self) { provider in
                    Button {
                        aiService.selectedProvider = provider
                    } label: {
                        HStack {
                            Text(provider.rawValue)
                            if aiService.selectedProvider == provider {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                if aiService.connectedProviders.isEmpty {
<<<<<<< HEAD
Text(NSLocalizedString("No providers connected", comment: "No providers connected"))
=======
                    Text("No providers connected")
>>>>>>> upstream/main
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
<<<<<<< HEAD
Button(NSLocalizedString("Manage AI Providers", comment: "Manage AI Providers")) {
menuBarManager.openMainWindowAndNavigate(to: NSLocalizedString("Enhancement", comment: "Enhancement"))
=======
                Button("Manage AI Providers") {
                    menuBarManager.openMainWindowAndNavigate(to: "Enhancement")
>>>>>>> upstream/main
                }
            } label: {
                HStack {
                    Text("AI Provider: \(aiService.selectedProvider.rawValue)")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
<<<<<<< HEAD
            
            Menu {
                ForEach(whisperState.usableModels, id: \.id) { model in
                    Button {
                        Task {
                            await whisperState.setDefaultTranscriptionModel(model)
                        }
                    } label: {
                        HStack {
                            Text(model.displayName)
                            if whisperState.currentTranscriptionModel?.id == model.id {
=======
            .disabled(!enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(aiService.availableModels, id: \.self) { model in
                    Button {
                        aiService.selectModel(model)
                    } label: {
                        HStack {
                            Text(model)
                            if aiService.currentModel == model {
>>>>>>> upstream/main
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
<<<<<<< HEAD
                Divider()
                
Button(NSLocalizedString("Manage Models", comment: "Manage Models")) {
menuBarManager.openMainWindowAndNavigate(to: NSLocalizedString("AI Models", comment: "AI Models"))
                }
            } label: {
                HStack {
Text("Model: \(whisperState.currentTranscriptionModel?.displayName ?? NSLocalizedString("None", comment: "None"))")
=======
                if aiService.availableModels.isEmpty {
                    Text("No models available")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Button("Manage AI Models") {
                    menuBarManager.openMainWindowAndNavigate(to: "Enhancement")
                }
            } label: {
                HStack {
                    Text("AI Model: \(aiService.currentModel)")
>>>>>>> upstream/main
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
<<<<<<< HEAD
            
            LanguageSelectionView(whisperState: whisperState, displayMode: .menuItem, whisperPrompt: whisperState.whisperPrompt)
            
Toggle(NSLocalizedString("Use Clipboard Context", comment: "Use Clipboard Context"), isOn: $enhancementService.useClipboardContext)
                .disabled(!enhancementService.isEnhancementEnabled)
            
Toggle(NSLocalizedString("Use Screen Context", comment: "Use Screen Context"), isOn: $enhancementService.useScreenCaptureContext)
                .disabled(!enhancementService.isEnhancementEnabled)
            
Menu(NSLocalizedString("Additional", comment: "Additional")) {
                Button {
                    whisperState.isAutoCopyEnabled.toggle()
                } label: {
                    HStack {
Text(NSLocalizedString("Auto-copy to Clipboard", comment: "Auto-copy to Clipboard"))
                        Spacer()
                        if whisperState.isAutoCopyEnabled {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    SoundManager.shared.isEnabled.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
Text(NSLocalizedString("Sound Feedback", comment: "Sound Feedback"))
                        Spacer()
                        if SoundManager.shared.isEnabled {
=======
            .disabled(!enhancementService.isEnhancementEnabled)
            
            LanguageSelectionView(whisperState: whisperState, displayMode: .menuItem, whisperPrompt: whisperState.whisperPrompt)
            
            Menu("Additional") {
                Button {
                    enhancementService.useClipboardContext.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
                        Text("Clipboard Context")
                        Spacer()
                        if enhancementService.useClipboardContext {
>>>>>>> upstream/main
                            Image(systemName: "checkmark")
                        }
                    }
                }
<<<<<<< HEAD
                
                Button {
                    MediaController.shared.isSystemMuteEnabled.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
Text(NSLocalizedString("Mute System Audio During Recording", comment: "Mute System Audio During Recording"))
                        Spacer()
                        if MediaController.shared.isSystemMuteEnabled {
=======
                .disabled(!enhancementService.isEnhancementEnabled)
                
                Button {
                    enhancementService.useScreenCaptureContext.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
                        Text("Context Awareness")
                        Spacer()
                        if enhancementService.useScreenCaptureContext {
>>>>>>> upstream/main
                            Image(systemName: "checkmark")
                        }
                    }
                }
<<<<<<< HEAD
=======
                .disabled(!enhancementService.isEnhancementEnabled)
>>>>>>> upstream/main
            }
            .id("additional-menu-\(menuRefreshTrigger)")
            
            Divider()
            
<<<<<<< HEAD
Button(NSLocalizedString("Copy Last Transcription", comment: "Copy Last Transcription")) {
                LastTranscriptionService.copyLastTranscription(from: whisperState.modelContext)
            }
            
            Button(NSLocalizedString("History", comment: "History")) {
                menuBarManager.openMainWindowAndNavigate(to: NSLocalizedString("History", comment: "History"))
            }
            
            Button(NSLocalizedString("Settings", comment: "Settings")) {
                menuBarManager.openMainWindowAndNavigate(to: NSLocalizedString("Settings", comment: "Settings"))
            }
            
            Button(menuBarManager.isMenuBarOnly ? NSLocalizedString("Show Dock Icon", comment: "Show Dock Icon") : NSLocalizedString("Hide Dock Icon", comment: "Hide Dock Icon")) {
                menuBarManager.toggleMenuBarOnly()
            }
            
            Toggle(NSLocalizedString("Launch at Login", comment: "Launch at Login"), isOn: $launchAtLoginEnabled)
                .onChange(of: launchAtLoginEnabled) { newValue in
=======
            Button("Retry Last Transcription") {
                LastTranscriptionService.retryLastTranscription(from: whisperState.modelContext, whisperState: whisperState)
            }
            
            Button("Copy Last Transcription") {
                LastTranscriptionService.copyLastTranscription(from: whisperState.modelContext)
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            
            Button("History") {
                menuBarManager.openMainWindowAndNavigate(to: "History")
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])
            
            Button("Settings") {
                menuBarManager.openMainWindowAndNavigate(to: "Settings")
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button(menuBarManager.isMenuBarOnly ? "Show Dock Icon" : "Hide Dock Icon") {
                menuBarManager.toggleMenuBarOnly()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            
            Toggle("Launch at Login", isOn: $launchAtLoginEnabled)
                .onChange(of: launchAtLoginEnabled) { oldValue, newValue in
>>>>>>> upstream/main
                    LaunchAtLogin.isEnabled = newValue
                }
            
            Divider()
            
<<<<<<< HEAD
Button(NSLocalizedString("Check for Updates", comment: "Check for Updates")) {
=======
            Button("Check for Updates") {
>>>>>>> upstream/main
                updaterViewModel.checkForUpdates()
            }
            .disabled(!updaterViewModel.canCheckForUpdates)
            
<<<<<<< HEAD
Button(NSLocalizedString("Help and Support", comment: "Help and Support")) {
=======
            Button("Help and Support") {
>>>>>>> upstream/main
                EmailSupport.openSupportEmail()
            }
            
            Divider()
            
<<<<<<< HEAD
Button(NSLocalizedString("Quit VoiceInk", comment: "Quit VoiceInk")) {
=======
            Button("Quit VoiceInk") {
>>>>>>> upstream/main
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
