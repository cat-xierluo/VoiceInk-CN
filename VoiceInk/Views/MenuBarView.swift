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
                
                Button(L10n.MenuBar.manageModels.text) {
                    menuBarManager.openMainWindowAndNavigate(to: "AI Models")
                }
            } label: {
                HStack {
                    Text(
                        L10n.MenuBar.transcriptionModel.format(
                            whisperState.currentTranscriptionModel?.displayName ?? L10n.Common.none.string
                        )
                    )
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            
            Divider()
            
            Toggle(L10n.MenuBar.aiEnhancement.text, isOn: $enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(enhancementService.allPrompts) { prompt in
                    Button {
                        enhancementService.setActivePrompt(prompt)
                    } label: {
                        HStack {
                            Image(systemName: prompt.icon)
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
                    Text(
                        L10n.MenuBar.prompt.format(
                            enhancementService.activePrompt?.title ?? L10n.Common.none.string
                        )
                    )
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
                            Text(provider.localizedName)
                            if aiService.selectedProvider == provider {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                if aiService.connectedProviders.isEmpty {
                    Text(L10n.MenuBar.noProviders.text)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Button(L10n.MenuBar.manageAIProviders.text) {
                    menuBarManager.openMainWindowAndNavigate(to: "Enhancement")
                }
            } label: {
                HStack {
                    Text(L10n.MenuBar.aiProvider.format(aiService.selectedProvider.localizedName))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            .disabled(!enhancementService.isEnhancementEnabled)
            
            Menu {
                ForEach(aiService.availableModels, id: \.self) { model in
                    Button {
                        aiService.selectModel(model)
                    } label: {
                        HStack {
                            Text(model)
                            if aiService.currentModel == model {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                if aiService.availableModels.isEmpty {
                    Text(L10n.MenuBar.noModels.text)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Button(L10n.MenuBar.manageAIModels.text) {
                    menuBarManager.openMainWindowAndNavigate(to: "Enhancement")
                }
            } label: {
                HStack {
                    Text(L10n.MenuBar.aiModel.format(aiService.currentModel))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
            }
            .disabled(!enhancementService.isEnhancementEnabled)
            
            LanguageSelectionView(whisperState: whisperState, displayMode: .menuItem, whisperPrompt: whisperState.whisperPrompt)
            
            Menu(L10n.MenuBar.additional.text) {
                Button {
                    enhancementService.useClipboardContext.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
                        Text(L10n.MenuBar.clipboardContext.text)
                        Spacer()
                        if enhancementService.useClipboardContext {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(!enhancementService.isEnhancementEnabled)
                
                Button {
                    enhancementService.useScreenCaptureContext.toggle()
                    menuRefreshTrigger.toggle()
                } label: {
                    HStack {
                        Text(L10n.MenuBar.contextAwareness.text)
                        Spacer()
                        if enhancementService.useScreenCaptureContext {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(!enhancementService.isEnhancementEnabled)
            }
            .id("additional-menu-\(menuRefreshTrigger)")
            
            Divider()
            
            Button(L10n.MenuBar.retryLast.text) {
                LastTranscriptionService.retryLastTranscription(from: whisperState.modelContext, whisperState: whisperState)
            }
            
            Button(L10n.MenuBar.copyLast.text) {
                LastTranscriptionService.copyLastTranscription(from: whisperState.modelContext)
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            
            Button(L10n.Sidebar.history.text) {
                menuBarManager.openMainWindowAndNavigate(to: "History")
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])
            
            Button(L10n.Sidebar.settings.text) {
                menuBarManager.openMainWindowAndNavigate(to: "Settings")
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button(menuBarManager.isMenuBarOnly ? L10n.MenuBar.showDockIcon.text : L10n.MenuBar.hideDockIcon.text) {
                menuBarManager.toggleMenuBarOnly()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            
            Toggle(L10n.MenuBar.launchAtLogin.text, isOn: $launchAtLoginEnabled)
                .onChange(of: launchAtLoginEnabled) { oldValue, newValue in
                    LaunchAtLogin.isEnabled = newValue
                }
            
            Divider()
            
            Button(L10n.MenuBar.checkForUpdates.text) {
                updaterViewModel.checkForUpdates()
            }
            .disabled(!updaterViewModel.canCheckForUpdates)
            
            Button(L10n.MenuBar.helpAndSupport.text) {
                EmailSupport.openSupportEmail()
            }
            
            Divider()
            
            Button(L10n.MenuBar.quit.text) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
