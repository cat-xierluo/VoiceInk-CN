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
Button(NSLocalizedString("Toggle Mini Recorder", comment: "Toggle Mini Recorder")) {
                Task {
                    await whisperState.toggleMiniRecorder()
                }
            }
            
Toggle(NSLocalizedString("AI Enhancement", comment: "AI Enhancement"), isOn: $enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(enhancementService.allPrompts) { prompt in
                    Button {
                        enhancementService.setActivePrompt(prompt)
                    } label: {
                        HStack {
                            Image(systemName: prompt.icon.rawValue)
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
Text("Prompt: \(enhancementService.activePrompt?.title ?? NSLocalizedString("None", comment: "None"))")
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
Text(NSLocalizedString("No providers connected", comment: "No providers connected"))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
Button(NSLocalizedString("Manage AI Providers", comment: "Manage AI Providers")) {
menuBarManager.openMainWindowAndNavigate(to: NSLocalizedString("Enhancement", comment: "Enhancement"))
                }
            } label: {
                HStack {
                    Text("AI Provider: \(aiService.selectedProvider.rawValue)")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
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
                
Button(NSLocalizedString("Manage Models", comment: "Manage Models")) {
menuBarManager.openMainWindowAndNavigate(to: NSLocalizedString("AI Models", comment: "AI Models"))
                }
            } label: {
                HStack {
Text("Model: \(whisperState.currentTranscriptionModel?.displayName ?? NSLocalizedString("None", comment: "None"))")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
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
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button {
                    MediaController.shared.isSystemMuteEnabled.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
Text(NSLocalizedString("Mute System Audio During Recording", comment: "Mute System Audio During Recording"))
                        Spacer()
                        if MediaController.shared.isSystemMuteEnabled {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .id("additional-menu-\(menuRefreshTrigger)")
            
            Divider()
            
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
                    LaunchAtLogin.isEnabled = newValue
                }
            
            Divider()
            
Button(NSLocalizedString("Check for Updates", comment: "Check for Updates")) {
                updaterViewModel.checkForUpdates()
            }
            .disabled(!updaterViewModel.canCheckForUpdates)
            
Button(NSLocalizedString("Help and Support", comment: "Help and Support")) {
                EmailSupport.openSupportEmail()
            }
            
            Divider()
            
Button(NSLocalizedString("Quit VoiceInk", comment: "Quit VoiceInk")) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
