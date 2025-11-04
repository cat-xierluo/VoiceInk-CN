import SwiftUI
import Cocoa
import KeyboardShortcuts
import LaunchAtLogin
import AVFoundation
<<<<<<< HEAD
// Additional imports for Settings components
=======
>>>>>>> upstream/main

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
<<<<<<< HEAD
    @State private var showResetOnboardingAlert = false
    @State private var currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
    @State private var isCustomCancelEnabled = false
=======
    @AppStorage("autoUpdateCheck") private var autoUpdateCheck = true
    @AppStorage("enableAnnouncements") private var enableAnnouncements = true
    @State private var showResetOnboardingAlert = false
    @State private var currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
    @State private var isCustomCancelEnabled = false

>>>>>>> upstream/main
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
<<<<<<< HEAD
                // Hotkey Selection Section
                SettingsSection(
                    icon: "gearshape.fill",
title: NSLocalizedString("VoiceInk Shortcut", comment: "VoiceInk Shortcut"),
subtitle: NSLocalizedString("Choose how you want to trigger VoiceInk", comment: "Choose how you want to trigger VoiceInk")
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        hotkeyView(
title: NSLocalizedString("Hotkey 1", comment: "Hotkey 1"),
=======
                SettingsSection(
                    icon: "command.circle",
                    title: "VoiceInk Shortcuts",
                    subtitle: "Choose how you want to trigger VoiceInk"
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        hotkeyView(
                            title: "Hotkey 1",
>>>>>>> upstream/main
                            binding: $hotkeyManager.selectedHotkey1,
                            shortcutName: .toggleMiniRecorder
                        )

<<<<<<< HEAD
                        // Hotkey 2 Configuration (Conditional)
                        if hotkeyManager.selectedHotkey2 != .none {
                            Divider()
                            hotkeyView(
title: NSLocalizedString("Hotkey 2", comment: "Hotkey 2"),
=======
                        if hotkeyManager.selectedHotkey2 != .none {
                            Divider()
                            hotkeyView(
                                title: "Hotkey 2",
>>>>>>> upstream/main
                                binding: $hotkeyManager.selectedHotkey2,
                                shortcutName: .toggleMiniRecorder2,
                                isRemovable: true,
                                onRemove: {
                                    withAnimation { hotkeyManager.selectedHotkey2 = .none }
                                }
                            )
                        }

<<<<<<< HEAD
                        // "Add another hotkey" button
=======
>>>>>>> upstream/main
                        if hotkeyManager.selectedHotkey1 != .none && hotkeyManager.selectedHotkey2 == .none {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation { hotkeyManager.selectedHotkey2 = .rightOption }
                                }) {
<<<<<<< HEAD
Label(NSLocalizedString("Add another hotkey", comment: "Add another hotkey"), systemImage: "plus.circle.fill")
=======
                                    Label("Add another hotkey", systemImage: "plus.circle.fill")
>>>>>>> upstream/main
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.accentColor)
                            }
                        }

<<<<<<< HEAD
Text(NSLocalizedString("Quick tap to start hands-free recording (tap again to stop). Press and hold for push-to-talk (release to stop recording).", comment: "Quick tap to start hands-free recording (tap again to stop). Press and hold for push-to-talk (release to stop recording)."))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()

                        // Cancel Recording Override Toggle
                        Toggle(isOn: $isCustomCancelEnabled) {
Text(NSLocalizedString("Override default double-tap Escape cancellation", comment: "Override default double-tap Escape cancellation"))
                        }
                        .toggleStyle(.switch)
                        .onChange(of: isCustomCancelEnabled) { _, newValue in
                            if !newValue {
                                KeyboardShortcuts.setShortcut(nil, for: .cancelRecorder)
                            }
                        }
                        
                        // Show shortcut recorder only when override is enabled
                        if isCustomCancelEnabled {
                            HStack(spacing: 12) {
Text(NSLocalizedString("Custom Cancel Shortcut", comment: "Custom Cancel Shortcut"))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                KeyboardShortcuts.Recorder(for: .cancelRecorder)
                                    .controlSize(.small)
                                
                                Spacer()
                            }
                            .padding(.leading, 16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

Text(NSLocalizedString("By default, double-tap Escape to cancel recordings. Enable override above for single-press custom cancellation (useful for Vim users).", comment: "By default, double-tap Escape to cancel recordings. Enable override above for single-press custom cancellation (useful for Vim users)."))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    }
                }

                // Recording Feedback Section
                SettingsSection(
                    icon: "speaker.wave.2.bubble.left.fill",
title: NSLocalizedString("Recording Feedback", comment: "Recording Feedback"),
subtitle: NSLocalizedString("Customize app & system feedback", comment: "Customize app & system feedback")
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $whisperState.isAutoCopyEnabled) {
Text(NSLocalizedString("Auto-copy to clipboard", comment: "Auto-copy to clipboard"))
                        }
                        .toggleStyle(.switch)

=======
                        Text("Quick tap to start hands-free recording (tap again to stop). Press and hold for push-to-talk (release to stop recording).")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SettingsSection(
                    icon: "keyboard.badge.ellipsis",
                    title: "Other App Shortcuts",
                    subtitle: "Additional shortcuts for VoiceInk"
                ) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Paste Last Transcript (Original)
                        HStack(spacing: 12) {
                            Text("Paste Last Transcript(Original)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            KeyboardShortcuts.Recorder(for: .pasteLastTranscription)
                                .controlSize(.small)
                            
                            InfoTip(
                                title: "Paste Last Transcript(Original)",
                                message: "Shortcut for pasting the most recent transcription."
                            )
                            
                            Spacer()
                        }

                        // Paste Last Transcript (Enhanced)
                        HStack(spacing: 12) {
                            Text("Paste Last Transcript(Enhanced)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            KeyboardShortcuts.Recorder(for: .pasteLastEnhancement)
                                .controlSize(.small)
                            
                            InfoTip(
                                title: "Paste Last Transcript(Enhanced)",
                                message: "Pastes the enhanced transcript if available, otherwise falls back to the original."
                            )
                            
                            Spacer()
                        }

                        

                        // Retry Last Transcription
                        HStack(spacing: 12) {
                            Text("Retry Last Transcription")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)

                            KeyboardShortcuts.Recorder(for: .retryLastTranscription)
                                .controlSize(.small)

                            InfoTip(
                                title: "Retry Last Transcription",
                                message: "Re-transcribe the last recorded audio using the current model and copy the result."
                            )

                            Spacer()
                        }

                        Divider()

                        
                        
                        // Custom Cancel Shortcut
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Toggle(isOn: $isCustomCancelEnabled.animation()) {
                                    Text("Custom Cancel Shortcut")
                                }
                                .toggleStyle(.switch)
                                .onChange(of: isCustomCancelEnabled) { _, newValue in
                                    if !newValue {
                                        KeyboardShortcuts.setShortcut(nil, for: .cancelRecorder)
                                    }
                                }
                                
                                InfoTip(
                                    title: "Dismiss Recording",
                                    message: "Shortcut for cancelling the current recording session. Default: double-tap Escape."
                                )
                            }
                            
                            if isCustomCancelEnabled {
                                HStack(spacing: 12) {
                                    Text("Cancel Shortcut")
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
                                Toggle("Enable Middle-Click Toggle", isOn: $hotkeyManager.isMiddleClickToggleEnabled.animation())
                                    .toggleStyle(.switch)
                                
                                InfoTip(
                                    title: "Middle-Click Toggle",
                                    message: "Use middle mouse button to toggle VoiceInk recording."
                                )
                            }

                            if hotkeyManager.isMiddleClickToggleEnabled {
                                HStack(spacing: 8) {
                                    Text("Activation Delay")
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
                                    
                                    Text("ms")
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
                    title: "Recording Feedback",
                    subtitle: "Customize app & system feedback"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
>>>>>>> upstream/main
                        Toggle(isOn: .init(
                            get: { SoundManager.shared.isEnabled },
                            set: { SoundManager.shared.isEnabled = $0 }
                        )) {
<<<<<<< HEAD
Text(NSLocalizedString("Sound feedback", comment: "Sound feedback"))
=======
                            Text("Sound feedback")
>>>>>>> upstream/main
                        }
                        .toggleStyle(.switch)

                        Toggle(isOn: $mediaController.isSystemMuteEnabled) {
<<<<<<< HEAD
Text(NSLocalizedString("Mute system audio during recording", comment: "Mute system audio during recording"))
                        }
                        .toggleStyle(.switch)
.help(NSLocalizedString("Automatically mute system audio when recording starts and restore when recording stops", comment: "Automatically mute system audio when recording starts and restore when recording stops"))

                        Toggle(isOn: $playbackController.isPauseMediaEnabled) {
Text(NSLocalizedString("Pause media during recording", comment: "Pause media during recording"))
                        }
                        .toggleStyle(.switch)
.help(NSLocalizedString("Automatically pause active media playback when recording starts and resume when recording stops", comment: "Automatically pause active media playback when recording starts and resume when recording stops"))
                    }
                }

                // Recorder Preference Section
                SettingsSection(
                    icon: "rectangle.on.rectangle",
title: NSLocalizedString("Recorder Style", comment: "Recorder Style"),
subtitle: NSLocalizedString("Choose your preferred recorder interface", comment: "Choose your preferred recorder interface")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("Select how you want the recorder to appear on your screen.", comment: "Select how you want the recorder to appear on your screen."))
                            .settingsDescription()
                        
Picker(NSLocalizedString("Recorder Style", comment: "Recorder Style"), selection: $whisperState.recorderType) {
Text(NSLocalizedString("Notch Recorder", comment: "Notch Recorder")).tag("notch")
Text(NSLocalizedString("Mini Recorder", comment: "Mini Recorder")).tag("mini")
=======
                            Text("Mute system audio during recording")
                        }
                        .toggleStyle(.switch)
                        .help("Automatically mute system audio when recording starts and restore when recording stops")

                        Toggle(isOn: Binding(
                            get: { UserDefaults.standard.bool(forKey: "preserveTranscriptInClipboard") },
                            set: { UserDefaults.standard.set($0, forKey: "preserveTranscriptInClipboard") }
                        )) {
                            Text("Preserve transcript in clipboard")
                        }
                        .toggleStyle(.switch)
                        .help("Keep the transcribed text in clipboard instead of restoring the original clipboard content")

                    }
                }

                PowerModeSettingsSection()

                ExperimentalFeaturesSection()

                SettingsSection(
                    icon: "rectangle.on.rectangle",
                    title: "Recorder Style",
                    subtitle: "Choose your preferred recorder interface"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select how you want the recorder to appear on your screen.")
                            .settingsDescription()
                        
                        Picker("Recorder Style", selection: $whisperState.recorderType) {
                            Text("Notch Recorder").tag("notch")
                            Text("Mini Recorder").tag("mini")
>>>>>>> upstream/main
                        }
                        .pickerStyle(.radioGroup)
                        .padding(.vertical, 4)
                    }
                }

<<<<<<< HEAD
                // Paste Method Section
                SettingsSection(
                    icon: "doc.on.clipboard",
title: NSLocalizedString("Paste Method", comment: "Paste Method"),
subtitle: NSLocalizedString("Choose how text is pasted", comment: "Choose how text is pasted")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("Select the method used to paste text. Use AppleScript if you have a non-standard keyboard layout.", comment: "Select the method used to paste text. Use AppleScript if you have a non-standard keyboard layout."))
                            .settingsDescription()
                        
Toggle(NSLocalizedString("Use AppleScript Paste Method", comment: "Use AppleScript Paste Method"), isOn: Binding(
=======
                SettingsSection(
                    icon: "doc.on.clipboard",
                    title: "Paste Method",
                    subtitle: "Choose how text is pasted"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select the method used to paste text. Use AppleScript if you have a non-standard keyboard layout.")
                            .settingsDescription()
                        
                        Toggle("Use AppleScript Paste Method", isOn: Binding(
>>>>>>> upstream/main
                            get: { UserDefaults.standard.bool(forKey: "UseAppleScriptPaste") },
                            set: { UserDefaults.standard.set($0, forKey: "UseAppleScriptPaste") }
                        ))
                        .toggleStyle(.switch)
                    }
                }

<<<<<<< HEAD
                // App Appearance Section
                SettingsSection(
                    icon: "dock.rectangle",
title: NSLocalizedString("App Appearance", comment: "App Appearance"),
subtitle: NSLocalizedString("Dock and Menu Bar options", comment: "Dock and Menu Bar options")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("Choose how VoiceInk appears in your system.", comment: "Choose how VoiceInk appears in your system."))
                            .settingsDescription()
                        
Toggle(NSLocalizedString("Hide Dock Icon (Menu Bar Only)", comment: "Hide Dock Icon (Menu Bar Only)"), isOn: $menuBarManager.isMenuBarOnly)
                            .toggleStyle(.switch)
                    }
                }

                // Audio Cleanup Section
                SettingsSection(
                    icon: "trash.circle",
title: NSLocalizedString("Audio Cleanup", comment: "Audio Cleanup"),
subtitle: NSLocalizedString("Manage recording storage", comment: "Manage recording storage")
                ) {
                    AudioCleanupSettingsView()
                }
                
                // Startup Section
                SettingsSection(
                    icon: "power",
title: NSLocalizedString("Startup", comment: "Startup"),
subtitle: NSLocalizedString("Launch options", comment: "Launch options")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("Choose whether VoiceInk should start automatically when you log in.", comment: "Choose whether VoiceInk should start automatically when you log in."))
                            .settingsDescription()
                        
                                                Toggle(NSLocalizedString("Launch at Login", comment: "Launch at Login"), isOn: .init(
                            get: { LaunchAtLogin.isEnabled },
                            set: { LaunchAtLogin.isEnabled = $0 }
                        ))
                        .toggleStyle(.switch)
                    }
                }
                
                // Updates Section
                SettingsSection(
                    icon: "arrow.triangle.2.circlepath",
title: NSLocalizedString("Updates", comment: "Updates"),
subtitle: NSLocalizedString("Keep VoiceInk up to date", comment: "Keep VoiceInk up to date")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("VoiceInk automatically checks for updates on launch and every other day.", comment: "VoiceInk automatically checks for updates on launch and every other day."))
                            .settingsDescription()
                        
Button(NSLocalizedString("Check for Updates Now", comment: "Check for Updates Now")) {
=======
                SettingsSection(
                    icon: "gear",
                    title: "General",
                    subtitle: "Appearance, startup, and updates"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Hide Dock Icon (Menu Bar Only)", isOn: $menuBarManager.isMenuBarOnly)
                            .toggleStyle(.switch)
                        
                        LaunchAtLogin.Toggle()
                            .toggleStyle(.switch)

                        Toggle("Enable automatic update checks", isOn: $autoUpdateCheck)
                            .toggleStyle(.switch)
                            .onChange(of: autoUpdateCheck) { _, newValue in
                                updaterViewModel.toggleAutoUpdates(newValue)
                            }
                        
                        Toggle("Show app announcements", isOn: $enableAnnouncements)
                            .toggleStyle(.switch)
                            .onChange(of: enableAnnouncements) { _, newValue in
                                if newValue {
                                    AnnouncementsService.shared.start()
                                } else {
                                    AnnouncementsService.shared.stop()
                                }
                            }
                        
                        Button("Check for Updates Now") {
>>>>>>> upstream/main
                            updaterViewModel.checkForUpdates()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(!updaterViewModel.canCheckForUpdates)
<<<<<<< HEAD
                    }
                }

                // Reset Onboarding Section
                SettingsSection(
                    icon: "arrow.counterclockwise",
title: NSLocalizedString("Reset Onboarding", comment: "Reset Onboarding"),
subtitle: NSLocalizedString("View the introduction again", comment: "View the introduction again")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
Text(NSLocalizedString("Reset the onboarding process to view the app introduction again.", comment: "Reset the onboarding process to view the app introduction again."))
                            .settingsDescription()
                        
Button(NSLocalizedString("Reset Onboarding", comment: "Reset Onboarding")) {
=======
                        
                        Divider()

                        Button("Reset Onboarding") {
>>>>>>> upstream/main
                            showResetOnboardingAlert = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
<<<<<<< HEAD

                // Data Management Section
                SettingsSection(
                    icon: "arrow.up.arrow.down.circle",
title: NSLocalizedString("Data Management", comment: "Data Management"),
subtitle: NSLocalizedString("Import or export your settings", comment: "Import or export your settings")
                ) {
                    VStack(alignment: .leading, spacing: 12) {
Text(NSLocalizedString("Export your custom prompts, power modes, word replacements, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export.", comment: "Export your custom prompts, power modes, word replacements, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export."))
=======
                
                SettingsSection(
                    icon: "lock.shield",
                    title: "Data & Privacy",
                    subtitle: "Control transcript history and storage"
                ) {
                    AudioCleanupSettingsView()
                }
                
                SettingsSection(
                    icon: "arrow.up.arrow.down.circle",
                    title: "Data Management",
                    subtitle: "Import or export your settings"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export your custom prompts, power modes, word replacements, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export.")
>>>>>>> upstream/main
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
<<<<<<< HEAD
Label(NSLocalizedString("Import Settings...", comment: "Import Settings..."), systemImage: "arrow.down.doc")
=======
                                Label("Import Settings...", systemImage: "arrow.down.doc")
>>>>>>> upstream/main
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
<<<<<<< HEAD
Label(NSLocalizedString("Export Settings...", comment: "Export Settings..."), systemImage: "arrow.up.doc")
=======
                                Label("Export Settings...", systemImage: "arrow.up.doc")
>>>>>>> upstream/main
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
<<<<<<< HEAD
            // Initialize custom cancel shortcut state from stored preferences
            isCustomCancelEnabled = KeyboardShortcuts.getShortcut(for: .cancelRecorder) != nil
        }
.alert(NSLocalizedString("Reset Onboarding", comment: "Reset Onboarding"), isPresented: $showResetOnboardingAlert) {
            Button(NSLocalizedString("Cancel", comment: "Cancel button"), role: .cancel) { }
Button(NSLocalizedString("Reset", comment: "Reset"), role: .destructive) {
=======
            isCustomCancelEnabled = KeyboardShortcuts.getShortcut(for: .cancelRecorder) != nil
        }
        .alert("Reset Onboarding", isPresented: $showResetOnboardingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
>>>>>>> upstream/main
                // Defer state change to avoid layout issues while alert dismisses
                DispatchQueue.main.async {
                    hasCompletedOnboarding = false
                }
            }
        } message: {
<<<<<<< HEAD
            Text(NSLocalizedString("Are you sure you want to reset the onboarding? You'll see the introduction screens again the next time you launch the app.", comment: "Are you sure you want to reset the onboarding? You'll see the introduction screens again the next time you launch the app."))
=======
            Text("Are you sure you want to reset the onboarding? You'll see the introduction screens again the next time you launch the app.")
>>>>>>> upstream/main
        }
    }
    
    @ViewBuilder
    private func hotkeyView(
        title: String,
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
<<<<<<< HEAD
                        .help(NSLocalizedString("Permission required for VoiceInk to function properly", comment: "Permission required for VoiceInk to function properly"))
=======
                        .help("Permission required for VoiceInk to function properly")
>>>>>>> upstream/main
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
<<<<<<< HEAD


=======
>>>>>>> upstream/main
