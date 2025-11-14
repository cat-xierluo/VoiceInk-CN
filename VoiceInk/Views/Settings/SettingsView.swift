import SwiftUI
import Cocoa
import KeyboardShortcuts
import LaunchAtLogin
import AVFoundation

struct SettingsView: View {
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var menuBarManager: MenuBarManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @StateObject private var deviceManager = AudioDeviceManager.shared
    @ObservedObject private var mediaController = MediaController.shared
    @ObservedObject private var playbackController = PlaybackController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("autoUpdateCheck") private var autoUpdateCheck = true
    @AppStorage("enableAnnouncements") private var enableAnnouncements = true
    @State private var showResetOnboardingAlert = false
    @State private var currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
    @State private var isCustomCancelEnabled = false

    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsSection(
                    icon: "command.circle",
                    title: L10n.Settings.Sections.hotkeysTitle.string,
                    subtitle: L10n.Settings.Sections.hotkeysSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        hotkeyView(
                            title: L10n.Settings.Hotkeys.primary.text,
                            binding: $hotkeyManager.selectedHotkey1,
                            shortcutName: .toggleMiniRecorder
                        )

                        if hotkeyManager.selectedHotkey2 != .none {
                            Divider()
                            hotkeyView(
                                title: L10n.Settings.Hotkeys.secondary.text,
                                binding: $hotkeyManager.selectedHotkey2,
                                shortcutName: .toggleMiniRecorder2,
                                isRemovable: true,
                                onRemove: {
                                    withAnimation { hotkeyManager.selectedHotkey2 = .none }
                                }
                            )
                        }

                        if hotkeyManager.selectedHotkey1 != .none && hotkeyManager.selectedHotkey2 == .none {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation { hotkeyManager.selectedHotkey2 = .rightOption }
                                }) {
                                    Label(L10n.Settings.Hotkeys.addAnother.text, systemImage: "plus.circle.fill")
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.accentColor)
                            }
                        }

                        Text(L10n.Settings.Hotkeys.quickTapDescription.text)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SettingsSection(
                    icon: "keyboard.badge.ellipsis",
                    title: L10n.Settings.Sections.otherShortcutsTitle.string,
                    subtitle: L10n.Settings.Sections.otherShortcutsSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Paste Last Transcript (Original)
                        HStack(spacing: 12) {
                            Text(L10n.Settings.Shortcuts.pasteOriginalTitle.text)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            KeyboardShortcuts.Recorder(for: .pasteLastTranscription)
                                .controlSize(.small)
                            
                            InfoTip(
                                title: L10n.Settings.Shortcuts.pasteOriginalTitle.string,
                                message: L10n.Settings.Shortcuts.pasteOriginalMessage.string
                            )
                            
                            Spacer()
                        }

                        // Paste Last Transcript (Enhanced)
                        HStack(spacing: 12) {
                            Text(L10n.Settings.Shortcuts.pasteEnhancedTitle.text)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            KeyboardShortcuts.Recorder(for: .pasteLastEnhancement)
                                .controlSize(.small)
                            
                            InfoTip(
                                title: L10n.Settings.Shortcuts.pasteEnhancedTitle.string,
                                message: L10n.Settings.Shortcuts.pasteEnhancedMessage.string
                            )
                            
                            Spacer()
                        }

                        

                        // Retry Last Transcription
                        HStack(spacing: 12) {
                            Text(L10n.MenuBar.retryLast.text)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            KeyboardShortcuts.Recorder(for: .retryLastTranscription)
                                .controlSize(.small)

                            InfoTip(
                                title: L10n.MenuBar.retryLast.string,
                                message: L10n.Settings.Shortcuts.retryMessage.string
                            )

                            Spacer()
                        }

                        Divider()

                        
                        
                        // Custom Cancel Shortcut
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Toggle(isOn: $isCustomCancelEnabled.animation()) {
                                    Text(L10n.Settings.CancelShortcut.toggleTitle.text)
                                }
                                .toggleStyle(.switch)
                                .onChange(of: isCustomCancelEnabled) { _, newValue in
                                    if !newValue {
                                        KeyboardShortcuts.setShortcut(nil, for: .cancelRecorder)
                                    }
                                }
                                
                                InfoTip(
                                    title: L10n.Settings.CancelShortcut.infoTitle.string,
                                    message: L10n.Settings.CancelShortcut.infoMessage.string
                                )
                            }
                            
                            if isCustomCancelEnabled {
                                HStack(spacing: 12) {
                                    Text(L10n.Settings.CancelShortcut.fieldLabel.text)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    KeyboardShortcuts.Recorder(for: .cancelRecorder)
                                        .controlSize(.small)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        Divider()
                        
                        // Middle-Click Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Toggle(L10n.Settings.MiddleClick.toggleTitle.text, isOn: $hotkeyManager.isMiddleClickToggleEnabled.animation())
                                    .toggleStyle(.switch)
                                
                                InfoTip(
                                    title: L10n.Settings.MiddleClick.infoTitle.string,
                                    message: L10n.Settings.MiddleClick.infoMessage.string
                                )
                            }

                            if hotkeyManager.isMiddleClickToggleEnabled {
                                HStack(spacing: 8) {
                                    Text(L10n.Settings.MiddleClick.activationDelay.text)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    TextField("", value: $hotkeyManager.middleClickActivationDelay, formatter: {
                                        let formatter = NumberFormatter()
                                        formatter.numberStyle = .none
                                        formatter.minimum = 0
                                        return formatter
                                    }())
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                                    .background(Color(NSColor.textBackgroundColor))
                                    .cornerRadius(5)
                                    .frame(width: 70)
                                    
                                    Text(L10n.Settings.MiddleClick.millisecondsSuffix.text)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                }

                SettingsSection(
                    icon: "speaker.wave.2.bubble.left.fill",
                    title: L10n.Settings.Sections.recordingFeedbackTitle.string,
                    subtitle: L10n.Settings.Sections.recordingFeedbackSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: .init(
                            get: { SoundManager.shared.isEnabled },
                            set: { SoundManager.shared.isEnabled = $0 }
                        )) {
                            Text(L10n.Settings.RecordingFeedback.sound.text)
                        }
                        .toggleStyle(.switch)

                        Toggle(isOn: $mediaController.isSystemMuteEnabled) {
                            Text(L10n.Settings.RecordingFeedback.muteSystemAudio.text)
                        }
                        .toggleStyle(.switch)
                        .help(L10n.Settings.RecordingFeedback.muteSystemAudioHelp.string)

                        Toggle(isOn: Binding(
                            get: { UserDefaults.standard.bool(forKey: "preserveTranscriptInClipboard") },
                            set: { UserDefaults.standard.set($0, forKey: "preserveTranscriptInClipboard") }
                        )) {
                            Text(L10n.Settings.RecordingFeedback.preserveClipboard.text)
                        }
                        .toggleStyle(.switch)
                        .help(L10n.Settings.RecordingFeedback.preserveClipboardHelp.string)

                    }
                }

                PowerModeSettingsSection()

                ExperimentalFeaturesSection()

                SettingsSection(
                    icon: "rectangle.on.rectangle",
                    title: L10n.Settings.Sections.recorderTitle.string,
                    subtitle: L10n.Settings.Sections.recorderSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.Settings.Recorder.description.text)
                            .settingsDescription()
                        
                        Picker(L10n.Settings.Sections.recorderTitle.text, selection: $whisperState.recorderType) {
                            Text(L10n.Settings.Recorder.notch.text).tag("notch")
                            Text(L10n.Settings.Recorder.mini.text).tag("mini")
                        }
                        .pickerStyle(.radioGroup)
                        .padding(.vertical, 4)
                    }
                }

                SettingsSection(
                    icon: "doc.on.clipboard",
                    title: L10n.Settings.Sections.pasteMethodTitle.string,
                    subtitle: L10n.Settings.Sections.pasteMethodSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.Settings.PasteMethod.description.text)
                            .settingsDescription()
                        
                        Toggle(L10n.Settings.PasteMethod.useAppleScript.text, isOn: Binding(
                            get: { UserDefaults.standard.bool(forKey: "UseAppleScriptPaste") },
                            set: { UserDefaults.standard.set($0, forKey: "UseAppleScriptPaste") }
                        ))
                        .toggleStyle(.switch)
                    }
                }

                SettingsSection(
                    icon: "gear",
                    title: L10n.Settings.Sections.generalTitle.string,
                    subtitle: L10n.Settings.Sections.generalSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(L10n.Settings.General.hideDockIcon.text, isOn: $menuBarManager.isMenuBarOnly)
                            .toggleStyle(.switch)
                        
                        LaunchAtLogin.Toggle(L10n.MenuBar.launchAtLogin.text)
                            .toggleStyle(.switch)

                        Toggle(L10n.Settings.General.enableAutoUpdateChecks.text, isOn: $autoUpdateCheck)
                            .toggleStyle(.switch)
                            .onChange(of: autoUpdateCheck) { _, newValue in
                                updaterViewModel.toggleAutoUpdates(newValue)
                            }
                        
                        Toggle(L10n.Settings.General.showAnnouncements.text, isOn: $enableAnnouncements)
                            .toggleStyle(.switch)
                            .onChange(of: enableAnnouncements) { _, newValue in
                                if newValue {
                                    AnnouncementsService.shared.start()
                                } else {
                                    AnnouncementsService.shared.stop()
                                }
                            }
                        
                        Button(L10n.Settings.General.checkForUpdatesNow.text) {
                            updaterViewModel.checkForUpdates()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(!updaterViewModel.canCheckForUpdates)
                        
                        Divider()

                        Button(L10n.Settings.General.resetOnboarding.text) {
                            showResetOnboardingAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                
                SettingsSection(
                    icon: "lock.shield",
                    title: L10n.Settings.Sections.dataPrivacyTitle.string,
                    subtitle: L10n.Settings.Sections.dataPrivacySubtitle.string
                ) {
                    AudioCleanupSettingsView()
                }
                
                SettingsSection(
                    icon: "arrow.up.arrow.down.circle",
                    title: L10n.Settings.Sections.dataManagementTitle.string,
                    subtitle: L10n.Settings.Sections.dataManagementSubtitle.string
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.Settings.Data.exportDescription.text)
                            .settingsDescription()

                        HStack(spacing: 12) {
                            Button {
                                ImportExportService.shared.importSettings(
                                    enhancementService: enhancementService, 
                                    whisperPrompt: whisperState.whisperPrompt, 
                                    hotkeyManager: hotkeyManager, 
                                    menuBarManager: menuBarManager, 
                                    mediaController: MediaController.shared, 
                                    playbackController: PlaybackController.shared,
                                    soundManager: SoundManager.shared,
                                    whisperState: whisperState
                                )
                            } label: {
                                Label(L10n.Settings.Data.importSettings.text, systemImage: "arrow.down.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)

                            Button {
                                ImportExportService.shared.exportSettings(
                                    enhancementService: enhancementService, 
                                    whisperPrompt: whisperState.whisperPrompt, 
                                    hotkeyManager: hotkeyManager, 
                                    menuBarManager: menuBarManager, 
                                    mediaController: MediaController.shared, 
                                    playbackController: PlaybackController.shared,
                                    soundManager: SoundManager.shared,
                                    whisperState: whisperState
                                )
                            } label: {
                                Label(L10n.Settings.Data.exportSettings.text, systemImage: "arrow.up.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .controlSize(.large)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            isCustomCancelEnabled = KeyboardShortcuts.getShortcut(for: .cancelRecorder) != nil
        }
        .alert(L10n.Settings.Alerts.resetTitle.text, isPresented: $showResetOnboardingAlert) {
            Button(L10n.Common.cancel.text, role: .cancel) { }
            Button(L10n.Common.reset.text, role: .destructive) {
                // Defer state change to avoid layout issues while alert dismisses
                DispatchQueue.main.async {
                    hasCompletedOnboarding = false
                }
            }
        } message: {
            Text(L10n.Settings.Alerts.resetMessage.text)
        }
    }
    
    @ViewBuilder
    private func hotkeyView(
        title: LocalizedStringKey,
        binding: Binding<HotkeyManager.HotkeyOption>,
        shortcutName: KeyboardShortcuts.Name,
        isRemovable: Bool = false,
        onRemove: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(HotkeyManager.HotkeyOption.allCases, id: \.self) { option in
                    Button(action: {
                        binding.wrappedValue = option
                    }) {
                        HStack {
                            Text(option.displayName)
                            if binding.wrappedValue == option {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(binding.wrappedValue.displayName)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)
            
            if binding.wrappedValue == .custom {
                KeyboardShortcuts.Recorder(for: shortcutName)
                    .controlSize(.small)
            }
            
            Spacer()
            
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    var showWarning: Bool = false
    
    init(icon: String, title: String, subtitle: String, showWarning: Bool = false, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showWarning = showWarning
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(showWarning ? .red : .accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(showWarning ? .red : .secondary)
                }
                
                if showWarning {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .help(L10n.Settings.Sections.permissionRequired.string)
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CardBackground(isSelected: showWarning, useAccentGradientWhenSelected: true))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(showWarning ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// Add this extension for consistent description text styling
extension Text {
    func settingsDescription() -> some View {
        self
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
