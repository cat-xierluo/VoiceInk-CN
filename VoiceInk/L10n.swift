import Foundation
import SwiftUI

/// Represents a single localized resource that can be used both with AppKit (`String`) and SwiftUI (`LocalizedStringKey`).
struct L10nItem {
    let key: String
    let comment: String

    init(_ key: String, comment: String = "") {
        self.key = key
        self.comment = comment
    }

    /// Localized string value, suitable for AppKit APIs such as `NSWindow.title`.
    var string: String {
        NSLocalizedString(key, comment: comment)
    }

    /// Localized key for SwiftUI views such as `Text`.
    var text: LocalizedStringKey {
        LocalizedStringKey(key)
    }

    /// Returns a formatted localized string using `%@`/`%d` placeholders.
    func format(_ arguments: CVarArg...) -> String {
        String(
            format: NSLocalizedString(key, comment: comment),
            locale: .current,
            arguments: arguments
        )
    }
}

enum L10n {
    enum Window {
        static let mainTitle = L10nItem("VoiceInk", comment: "Main window title")
        static let onboardingTitle = L10nItem("VoiceInk Onboarding", comment: "Onboarding window title")
    }

    enum Debug {
        static let windowTitle = L10nItem("Debug", comment: "Debug window title")
        static let toggleMenuBarOnly = L10nItem("Toggle Menu Bar Only", comment: "Toggle menu bar only debug option")
    }

    enum App {
        static let name = L10nItem("VoiceInk", comment: "Application name displayed in sidebar")
        static let proBadge = L10nItem("PRO", comment: "Pro badge short label")
    }

    enum Common {
        static let none = L10nItem("None", comment: "Generic fallback when no item is selected")
        static let cancel = L10nItem("Cancel", comment: "Generic cancel action button")
        static let ok = L10nItem("OK", comment: "Generic OK action button")
        static let error = L10nItem("Error", comment: "Generic error title")
        static let reset = L10nItem("Reset", comment: "Generic reset action button")
        static let pro = L10nItem("PRO", comment: "PRO badge text")
        static let selectSection = L10nItem("Select Section", comment: "Select section label")
        static let buyLicense = L10nItem("Buy License", comment: "Buy license button")
        static let add = L10nItem("Add", comment: "Add button")
        static let save = L10nItem("Save", comment: "Save button")
        static let saveChanges = L10nItem("Save Changes", comment: "Save changes button")
        static let edit = L10nItem("Edit", comment: "Edit button")
        static let export = L10nItem("Export", comment: "Export button")
        static let delete = L10nItem("Delete", comment: "Delete button")
        static let analyze = L10nItem("Analyze", comment: "Analyze button")
        static let learnMore = L10nItem("Learn more", comment: "Learn more link")
        static let dismiss = L10nItem("Dismiss", comment: "Dismiss button")
        static let done = L10nItem("Done", comment: "Done button")
        static let unknown = L10nItem("Unknown", comment: "Unknown label")
    }

    enum Sidebar {
        static let dashboard = L10nItem("Dashboard", comment: "Sidebar item: Dashboard")
        static let transcribeAudio = L10nItem("Transcribe Audio", comment: "Sidebar item: Transcribe Audio")
        static let history = L10nItem("History", comment: "Sidebar item: History")
        static let models = L10nItem("AI Models", comment: "Sidebar item: AI Models")
        static let enhancement = L10nItem("Enhancement", comment: "Sidebar item: Enhancement")
        static let powerMode = L10nItem("Power Mode", comment: "Sidebar item: Power Mode")
        static let permissions = L10nItem("Permissions", comment: "Sidebar item: Permissions")
        static let audioInput = L10nItem("Audio Input", comment: "Sidebar item: Audio Input")
        static let dictionary = L10nItem("Dictionary", comment: "Sidebar item: Dictionary")
        static let settings = L10nItem("Settings", comment: "Sidebar item: Settings")
        static let license = L10nItem("VoiceInk Pro", comment: "Sidebar item: VoiceInk Pro subscription")
    }

    enum MenuBar {
        static let manageModels = L10nItem("Manage Models", comment: "Menu bar action to open transcription models")
        static let manageAIModels = L10nItem("Manage AI Models", comment: "Menu bar action to open AI models management")
        static let transcriptionModel = L10nItem("Transcription Model: %@", comment: "Menu bar label showing the current transcription model")
        static let aiEnhancement = L10nItem("AI Enhancement", comment: "Menu bar toggle for AI enhancement")
        static let prompt = L10nItem("Prompt: %@", comment: "Menu bar label showing the selected prompt")
        static let noProviders = L10nItem("No providers connected", comment: "Menu bar placeholder when no AI providers are available")
        static let manageAIProviders = L10nItem("Manage AI Providers", comment: "Menu bar action to open AI providers settings")
        static let aiProvider = L10nItem("AI Provider: %@", comment: "Menu bar label showing the selected AI provider")
        static let noModels = L10nItem("No models available", comment: "Menu bar placeholder when no AI models are available")
        static let aiModel = L10nItem("AI Model: %@", comment: "Menu bar label showing the selected AI enhancement model")
        static let additional = L10nItem("Additional", comment: "Menu bar section for additional options")
        static let clipboardContext = L10nItem("Clipboard Context", comment: "Menu item for clipboard context toggle")
        static let contextAwareness = L10nItem("Context Awareness", comment: "Menu item for screen context toggle")
        static let retryLast = L10nItem("Retry Last Transcription", comment: "Menu bar action to retry the last transcription")
        static let copyLast = L10nItem("Copy Last Transcription", comment: "Menu bar action to copy the last transcription")
        static let showDockIcon = L10nItem("Show Dock Icon", comment: "Menu bar action to show the dock icon")
        static let hideDockIcon = L10nItem("Hide Dock Icon", comment: "Menu bar action to hide the dock icon")
        static let launchAtLogin = L10nItem("Launch at Login", comment: "Menu bar toggle for launch-at-login preference")
        static let checkForUpdates = L10nItem("Check for Updates", comment: "Menu bar action to check for updates")
        static let helpAndSupport = L10nItem("Help and Support", comment: "Menu bar action to open help resources")
        static let quit = L10nItem("Quit VoiceInk", comment: "Menu bar action to quit the app")
    }

    enum Settings {
        enum Sections {
            static let hotkeysTitle = L10nItem("VoiceInk Shortcuts", comment: "Settings section title for VoiceInk shortcuts")
            static let hotkeysSubtitle = L10nItem("Choose how you want to trigger VoiceInk", comment: "Settings section subtitle for VoiceInk shortcuts")
            static let otherShortcutsTitle = L10nItem("Other App Shortcuts", comment: "Settings section title for additional shortcuts")
            static let otherShortcutsSubtitle = L10nItem("Additional shortcuts for VoiceInk", comment: "Settings section subtitle for additional shortcuts")
            static let recordingFeedbackTitle = L10nItem("Recording Feedback", comment: "Settings section title for recording feedback")
            static let recordingFeedbackSubtitle = L10nItem("Customize app & system feedback", comment: "Settings section subtitle for recording feedback")
            static let recorderTitle = L10nItem("Recorder Style", comment: "Settings section title for recorder style")
            static let recorderSubtitle = L10nItem("Choose your preferred recorder interface", comment: "Settings section subtitle for recorder style")
            static let pasteMethodTitle = L10nItem("Paste Method", comment: "Settings section title for paste method")
            static let pasteMethodSubtitle = L10nItem("Choose how text is pasted", comment: "Settings section subtitle for paste method")
            static let generalTitle = L10nItem("General", comment: "Settings section title for general preferences")
            static let generalSubtitle = L10nItem("Appearance, startup, and updates", comment: "Settings section subtitle for general preferences")
            static let dataPrivacyTitle = L10nItem("Data & Privacy", comment: "Settings section title for data and privacy")
            static let dataPrivacySubtitle = L10nItem("Control transcript history and storage", comment: "Settings section subtitle for data and privacy")
            static let dataManagementTitle = L10nItem("Data Management", comment: "Settings section title for data management")
            static let dataManagementSubtitle = L10nItem("Import or export your settings", comment: "Settings section subtitle for data management")
        static let permissionRequired = L10nItem("Permission required for VoiceInk to function properly", comment: "Tooltip text explaining permission requirement")
        }

        static let heroDescription = L10nItem("Manage VoiceInk settings and preferences", comment: "Settings hero description")

        static let description = L10nItem("Manage VoiceInk settings and preferences", comment: "Settings hero description")

        enum Hotkeys {
            static let primary = L10nItem("Hotkey 1", comment: "Label for primary shortcut slot")
            static let secondary = L10nItem("Hotkey 2", comment: "Label for secondary shortcut slot")
            static let addAnother = L10nItem("Add another hotkey", comment: "Button label to add another hotkey")
            static let quickTapDescription = L10nItem("Quick tap to start hands-free recording (tap again to stop). Press and hold for push-to-talk (release to stop recording).", comment: "Description for VoiceInk hotkey behavior")
        }

        enum Shortcuts {
            static let pasteOriginalTitle = L10nItem("Paste Last Transcript(Original)", comment: "Shortcut label for pasting original transcript")
            static let pasteOriginalMessage = L10nItem("Shortcut for pasting the most recent transcription.", comment: "Info tip message for pasting original transcript")
            static let pasteEnhancedTitle = L10nItem("Paste Last Transcript(Enhanced)", comment: "Shortcut label for pasting enhanced transcript")
            static let pasteEnhancedMessage = L10nItem("Pastes the enhanced transcript if available, otherwise falls back to the original.", comment: "Info tip message for pasting enhanced transcript")
            static let retryMessage = L10nItem("Re-transcribe the last recorded audio using the current model and copy the result.", comment: "Info tip message for retrying last transcription")
        }

        enum CancelShortcut {
            static let toggleTitle = L10nItem("Custom Cancel Shortcut", comment: "Toggle title for custom cancel shortcut")
            static let infoTitle = L10nItem("Dismiss Recording", comment: "Info tip title for cancel shortcut")
            static let infoMessage = L10nItem("Shortcut for cancelling the current recording session. Default: double-tap Escape.", comment: "Info tip message for cancel shortcut")
            static let fieldLabel = L10nItem("Cancel Shortcut", comment: "Label for cancel shortcut recorder field")
        }

        enum MiddleClick {
            static let toggleTitle = L10nItem("Enable Middle-Click Toggle", comment: "Toggle title for middle-click recording")
            static let infoTitle = L10nItem("Middle-Click Toggle", comment: "Info tip title for middle-click toggle")
            static let infoMessage = L10nItem("Use middle mouse button to toggle VoiceInk recording.", comment: "Info tip message for middle-click toggle")
            static let activationDelay = L10nItem("Activation Delay", comment: "Label for middle-click activation delay")
            static let millisecondsSuffix = L10nItem("ms", comment: "Milliseconds unit suffix")
        }

        enum RecordingFeedback {
            static let sound = L10nItem("Sound feedback", comment: "Toggle label for enabling sound feedback")
            static let muteSystemAudio = L10nItem("Mute system audio during recording", comment: "Toggle label for muting system audio")
            static let muteSystemAudioHelp = L10nItem("Automatically mute system audio when recording starts and restore when recording stops", comment: "Help text for muting system audio toggle")
            static let preserveClipboard = L10nItem("Preserve transcript in clipboard", comment: "Toggle label for preserving clipboard contents")
            static let preserveClipboardHelp = L10nItem("Keep the transcribed text in clipboard instead of restoring the original clipboard content", comment: "Help text for preserving clipboard toggle")
        }

        enum Recorder {
            static let description = L10nItem("Select how you want the recorder to appear on your screen.", comment: "Description for recorder style options")
            static let notch = L10nItem("Notch Recorder", comment: "Recorder style option for notch mode")
            static let mini = L10nItem("Mini Recorder", comment: "Recorder style option for mini mode")
        }

        enum PasteMethod {
            static let description = L10nItem("Select the method used to paste text. Use AppleScript if you have a non-standard keyboard layout.", comment: "Description for paste method options")
            static let useAppleScript = L10nItem("Use AppleScript Paste Method", comment: "Toggle label for enabling AppleScript paste method")
        }

        enum General {
            static let hideDockIcon = L10nItem("Hide Dock Icon (Menu Bar Only)", comment: "Toggle label for hiding dock icon")
            static let enableAutoUpdateChecks = L10nItem("Enable automatic update checks", comment: "Toggle label for automatic update checks")
            static let showAnnouncements = L10nItem("Show app announcements", comment: "Toggle label for showing announcements")
            static let checkForUpdatesNow = L10nItem("Check for Updates Now", comment: "Button label for checking updates immediately")
            static let resetOnboarding = L10nItem("Reset Onboarding", comment: "Button label for resetting onboarding")
        }

        enum Data {
            static let exportDescription = L10nItem("Export your custom prompts, power modes, word replacements, keyboard shortcuts, and app preferences to a backup file. API keys are not included in the export.", comment: "Description for exporting settings")
            static let importSettings = L10nItem("Import Settings...", comment: "Button label for importing settings")
            static let exportSettings = L10nItem("Export Settings...", comment: "Button label for exporting settings")
            static let configureApiKeys = L10nItem("Configure API Keys", comment: "Button label to configure API keys after importing settings")
        }

        enum DataImport {
            static let successMessage = L10nItem("Settings imported successfully from %@. All settings (including general app settings) have been applied.", comment: "Import success message with file name")
            static let errorTitle = L10nItem("Import Error", comment: "Import error alert title")
            static let errorMessage = L10nItem("Error importing settings: %@. The file might be corrupted or not in the correct format.", comment: "Import error alert message")
            static let canceledTitle = L10nItem("Import Canceled", comment: "Import canceled alert title")
            static let canceledMessage = L10nItem("The settings import operation was canceled.", comment: "Import canceled alert message")
            static let successTitle = L10nItem("Import Successful", comment: "Import success alert title")
            static let restartInfo = L10nItem("IMPORTANT: If you were using AI enhancement features, please make sure to reconfigure your API keys in the Enhancement section.\n\nIt is recommended to restart VoiceInk for all changes to take full effect.", comment: "Import restart recommendation message")
        }

        enum Alerts {
            static let resetTitle = L10nItem("Reset Onboarding", comment: "Alert title for resetting onboarding")
            static let resetMessage = L10nItem("Are you sure you want to reset the onboarding? You'll see the introduction screens again the next time you launch the app.", comment: "Alert message for resetting onboarding")
        }
    }

    enum License {
        static let upgradeToPro = L10nItem("Upgrade to Pro", comment: "Upsell heading for upgrading to Pro")
        static let versionFormat = L10nItem("v%@", comment: "Displayed app version with leading v")
        static let supportMessage = L10nItem("Thank you for supporting VoiceInk", comment: "Message shown to licensed users")
        static let heroSubtitle = L10nItem("Transcribe what you say to text instantly with AI", comment: "Subtitle encouraging upgrade")
        static let trialEndingSoon = L10nItem("Trial ending soon", comment: "Trial warning heading")
        static let trialExpired = L10nItem("Trial expired", comment: "Trial expired heading")
        static let trialActive = L10nItem("Trial active", comment: "Trial active heading")

        static let changelog = L10nItem("Changelog", comment: "Link to release changelog")
        static let discord = L10nItem("Discord", comment: "Link to Discord community")
        static let emailSupport = L10nItem("Email Support", comment: "Link to send support email")
        static let docs = L10nItem("Docs", comment: "Link to documentation")
        static let roadmap = L10nItem("Roadmap", comment: "Link to roadmap")

        static let buyOnceOwnForever = L10nItem("Buy Once, Own Forever", comment: "Lifetime purchase badge copy")
        static let upgradeToVoiceInkPro = L10nItem("Upgrade to VoiceInk Pro", comment: "Call to action button for purchasing Pro")

        static let prioritySupport = L10nItem("Priority Support", comment: "Feature highlight: priority support")
        static let lifetimeAccess = L10nItem("Lifetime Access", comment: "Feature highlight: lifetime access")
        static let freeUpdates = L10nItem("Free Updates", comment: "Feature highlight: free updates")
        static let multipleDevices = L10nItem("Multiple Devices", comment: "Feature highlight: supports multiple devices")

        static let alreadyHaveLicense = L10nItem("Already have a license?", comment: "Prompt for existing license owners")
        static let enterLicenseKey = L10nItem("Enter your license key", comment: "Placeholder for license key field")
        static let activate = L10nItem("Activate", comment: "Button to activate license")
        static let activateLicense = L10nItem("Activate License", comment: "Button text for license activation")
        static let premiumActivated = L10nItem("Premium Activated", comment: "Status text shown when premium is active")
        static let removeLicense = L10nItem("Remove License", comment: "Button text for removing license")

        static let licenseActive = L10nItem("License Active", comment: "Heading shown when license is active")
        static let activeStatus = L10nItem("Active", comment: "Tag indicating active status")
        static let activationLimitMessage = L10nItem("This license can be activated on up to %d devices", comment: "Message showing device activation limit")
        static let allDevicesMessage = L10nItem("You can use VoiceInk Pro on all your personal devices", comment: "Message indicating unlimited device usage")

        static let licenseManagement = L10nItem("License Management", comment: "Section header for managing license")
        static let management = licenseManagement
        static let deactivateLicense = L10nItem("Deactivate License", comment: "Action label to deactivate license")
        static let tipJar = L10nItem("Tip Jar", comment: "Tip jar label")
    }

    enum Onboarding {
        static let welcomeTitle = L10nItem("Welcome to the Future of Typing", comment: "Main welcome title on onboarding screen")
        static let welcomeSubtitle = L10nItem("A New Way to Type", comment: "Subtitle on onboarding screen")
        static let getStarted = L10nItem("Get Started", comment: "Button to start onboarding")
        static let skipTour = L10nItem("Skip Tour", comment: "Button to skip the onboarding tour")

        enum Typewriter {
            static let role1 = L10nItem("Your Writing Assistant", comment: "First typewriter role description")
            static let role2 = L10nItem("Your Vibe-Coding Assistant", comment: "Second typewriter role description")
            static let role3 = L10nItem("Works Everywhere on Mac with a click", comment: "Third typewriter role description")
            static let role4 = L10nItem("100% offline & private", comment: "Fourth typewriter role description")
        }

        enum Tutorial {
            static let tryItOut = L10nItem("Try It Out!", comment: "Tutorial section title")
            static let testSetup = L10nItem("Let's test your VoiceInk setup.", comment: "Tutorial subtitle")
            static let yourShortcut = L10nItem("Your Shortcut", comment: "Label for showing user's keyboard shortcut")
            static let completeSetup = L10nItem("Complete Setup", comment: "Button to complete the setup")
            static let skipForNow = L10nItem("Skip for now", comment: "Button to skip the tutorial")
            static let clickToSpeak = L10nItem("Click here and start speaking...", comment: "Placeholder text in tutorial text editor")

            enum Instructions {
                static let step1 = L10nItem("Click the text area on the right", comment: "First instruction step")
                static let step2 = L10nItem("Press your shortcut key", comment: "Second instruction step")
                static let step3 = L10nItem("Speak something", comment: "Third instruction step")
                static let step4 = L10nItem("Press your shortcut key again", comment: "Fourth instruction step")
            }
        }

        enum Permissions {
            enum Microphone {
                static let title = L10nItem("Microphone Access", comment: "Microphone permission title")
                static let description = L10nItem("Enable your microphone to start speaking and converting your voice to text instantly.", comment: "Microphone permission description")
            }

            enum MicrophoneSelection {
                static let title = L10nItem("Microphone Selection", comment: "Microphone selection permission title")
                static let description = L10nItem("Select the audio input device you want to use with VoiceInk.", comment: "Microphone selection permission description")
                static let noMicrophonesFound = L10nItem("No microphones found", comment: "Message when no microphones are available")
                static let recommendedTip = L10nItem("For best results, using your Mac's built-in microphone is recommended.", comment: "Tip about using built-in microphone")
                static let microphoneLabel = L10nItem("Microphone:", comment: "Label for microphone selection dropdown")
                static let selectDevice = L10nItem("Select Device", comment: "Default text when no device is selected")
            }

            enum Accessibility {
                static let title = L10nItem("Accessibility Access", comment: "Accessibility permission title")
                static let description = L10nItem("Allow VoiceInk to help you type anywhere in your Mac.", comment: "Accessibility permission description")
            }

            enum ScreenRecording {
                static let title = L10nItem("Screen Recording", comment: "Screen recording permission title")
                static let description = L10nItem("This helps to improve the accuracy of transcription.", comment: "Screen recording permission description")
                static let infoTipTitle = L10nItem("Screen Recording Access", comment: "Info tip title for screen recording")
                static let infoTipMessage = L10nItem("VoiceInk captures on-screen text to understand the context of your voice input, which significantly improves transcription accuracy. Your privacy is important: this data is processed locally and is not stored.", comment: "Info tip message for screen recording")
            }

            enum KeyboardShortcut {
                static let title = L10nItem("Keyboard Shortcut", comment: "Keyboard shortcut permission title")
                static let description = L10nItem("Set up a keyboard shortcut to quickly access VoiceInk from anywhere.", comment: "Keyboard shortcut permission description")
                static let shortcutLabel = L10nItem("Shortcut:", comment: "Label for shortcut selection")
            }

            enum Buttons {
                static let `continue` = L10nItem("Continue", comment: "Continue button")
                static let setShortcut = L10nItem("Set Shortcut", comment: "Set shortcut button")
                static let enableAccess = L10nItem("Enable Access", comment: "Enable access button")
                static let skipForNow = L10nItem("Skip for now", comment: "Skip for now button")
            }
        }

        enum ModelDownload {
            static let title = L10nItem("Download AI Model", comment: "Model download screen title")
            static let description = L10nItem("We'll download the optimized model to get you started.", comment: "Model download screen description")
            static let skipForNow = L10nItem("Skip for now", comment: "Skip model download button")
            static let `continue` = L10nItem("Continue", comment: "Continue button")
            static let downloading = L10nItem("Downloading...", comment: "Downloading status")
            static let setAsDefault = L10nItem("Set as Default", comment: "Set as default button")
            static let downloadModel = L10nItem("Download Model", comment: "Download model button")
            static let speed = L10nItem("Speed", comment: "Speed indicator label")
            static let accuracy = L10nItem("Accuracy", comment: "Accuracy indicator label")
            static let ram = L10nItem("RAM", comment: "RAM usage label")
        }
    }

    enum Dictionary {
        static let title = L10nItem("Add words to help VoiceInk recognize them properly. (Requires AI enhancement)", comment: "Dictionary info description")
        static let addWordPlaceholder = L10nItem("Add word to dictionary", comment: "TextField placeholder for adding words")
        static let addWordHelp = L10nItem("Add word", comment: "Help text for add word button")
        static let replacement = L10nItem("Replacement", comment: "Dictionary replacement label")
        static let description = L10nItem("Manage custom words and replacements so VoiceInk understands you more accurately.", comment: "Dictionary settings hero description")
        static let itemsTitle = L10nItem("Dictionary Items", comment: "Title for dictionary items list")
        static let itemsCount = L10nItem("Dictionary Items (%d)", comment: "Dictionary items label with count")
        static let alertTitle = L10nItem("Dictionary", comment: "Dictionary alert title")
        static let ok = L10nItem("OK", comment: "OK button")
        static let alreadyExists = L10nItem("'%@' is already in the dictionary", comment: "Error message when word already exists")
        static let wordReplacements = L10nItem("Word Replacements", comment: "Word replacements section title")
        static let correctSpellings = L10nItem("Correct Spellings", comment: "Correct spellings section title")
        static let wordReplacementsDescription = L10nItem("Automatically replace specific words/phrases with custom formatted text", comment: "Word replacements section description")
        static let correctSpellingsDescription = L10nItem("Add words to help VoiceInk recognize them properly", comment: "Correct spellings section description")
    }

    enum PromptEditor {
        static let editTriggerWords = L10nItem("Edit Trigger Words", comment: "Title when editing trigger words")
        static let newPrompt = L10nItem("New Prompt", comment: "Title when creating new prompt")
        static let editPrompt = L10nItem("Edit Prompt", comment: "Title when editing prompt")
        static let cancel = L10nItem("Cancel", comment: "Cancel button")
        static let save = L10nItem("Save", comment: "Save button")
        static let editing = L10nItem("Editing: %@", comment: "Title showing which prompt is being edited")
        static let systemPromptRestriction = L10nItem("You can only customize the trigger words for system prompts.", comment: "Info message for system prompts")
        static let title = L10nItem("Title", comment: "Title field label")
        static let titlePlaceholder = L10nItem("Enter a short, descriptive title", comment: "Placeholder for title field")
        static let icon = L10nItem("Icon", comment: "Icon field label")
        static let description = L10nItem("Description", comment: "Description field label")
        static let descriptionPlaceholder = L10nItem("Enter a description", comment: "Placeholder for description field")
        static let descriptionHelp = L10nItem("Add a brief description of what this prompt does", comment: "Help text for description field")
        static let promptInstructions = L10nItem("Prompt Instructions", comment: "Prompt instructions label")
        static let promptInstructionsHelp = L10nItem("Define how AI should enhance your transcriptions", comment: "Help text for prompt instructions")
        static let useSystemInstructions = L10nItem("Use System Instructions", comment: "Toggle for system instructions")
        static let systemInstructions = L10nItem("System Instructions", comment: "System instructions label")
        static let systemInstructionsHelp = L10nItem("If enabled, your instructions are combined with a general-purpose template to improve transcription quality.\n\nDisable for full control over the AI's system prompt (for advanced users).", comment: "Help text for system instructions")
        static let predefinedTemplate = L10nItem("Start with a Predefined Template", comment: "Button to start with template")
        static let triggerWords = L10nItem("Trigger Words", comment: "Trigger words label")
        static let triggerWordsHelp = L10nItem("Add multiple words that can activate this prompt", comment: "Help text for trigger words")
        static let addTriggerPlaceholder = L10nItem("Add trigger word", comment: "Placeholder to add trigger word")
        static let removeTriggerHelp = L10nItem("Remove trigger word", comment: "Help text for removing trigger word")
        static let deletePromptTitle = L10nItem("Delete Prompt?", comment: "Delete prompt alert title")
        static let deletePromptMessage = L10nItem("Are you sure you want to delete the \"%@\" prompt? This action cannot be undone.", comment: "Delete prompt alert message")
    }

    enum PowerMode {
        static let title = L10nItem("Power Mode", comment: "Power mode section title")
        static let description = L10nItem("Enable to automatically apply custom configurations based on the app or website you are using.", comment: "Power mode section description")
        static let enable = L10nItem("Enable Power Mode", comment: "Enable power mode toggle")
        static let autoRestore = L10nItem("Auto-Restore Preferences", comment: "Auto-restore preferences label")
        static let autoRestoreHelp = L10nItem("After each recording session, revert enhancement and transcription preferences to whatever was configured before Power Mode was activated.", comment: "Help text for auto-restore")
        static let stillActive = L10nItem("Power Mode Still Active", comment: "Alert title when power mode can't be disabled")
        static let gotIt = L10nItem("Got it", comment: "Got it button")
        static let cantDisable = L10nItem("Power Mode can't be disabled while any configuration is still enabled. Disable or remove your Power Modes first.", comment: "Alert message when power mode can't be disabled")
        static let fixValidationErrors = L10nItem("Please fix the validation errors before saving.", comment: "Power mode validation error message")
        static let noPowerModes = L10nItem("No Power Modes", comment: "No power modes label")
        static let addPowerModesDescription = L10nItem("Add customized power modes for different contexts", comment: "Add power modes description")
        static let `default` = L10nItem("Default", comment: "Default label")
        static let autoSend = L10nItem("Auto Send", comment: "Auto send label")
        static let contextAwareness = L10nItem("Context Awareness", comment: "Context awareness label")
        static let selectApplications = L10nItem("Select Applications", comment: "Select applications label")
        static let powerModes = L10nItem("Power Modes", comment: "Power modes title")
        static let automateWorkflows = L10nItem("Automate your workflows with context-aware configurations.", comment: "Automate workflows description")
        static let addPowerMode = L10nItem("Add Power Mode", comment: "Add power mode button")
        static let disabled = L10nItem("Disabled", comment: "Disabled label")
        static let noPowerModesYet = L10nItem("No Power Modes Yet", comment: "No power modes yet message")
        static let createFirstPowerMode = L10nItem("Create first power mode to automate your VoiceInk workflow based on apps/website you are using", comment: "Create first power mode description")
        static let emojiPickerTip = L10nItem("Tip: Use ⌃⌘Space for emoji picker.", comment: "Emoji picker tip")
        static let addEmoji = L10nItem("Add Emoji", comment: "Add emoji button label")
        static let aiLabel = L10nItem("AI", comment: "Fallback label for AI tag")
        static let selectPowerMode = L10nItem("Select Power Mode", comment: "Select power mode label")
        static let noPowerModesAvailable = L10nItem("No Power Modes Available", comment: "No power modes available message")
        static let applications = L10nItem("Applications", comment: "Applications label")
        static let noApplicationsAdded = L10nItem("No applications added", comment: "No applications added message")
        static let websites = L10nItem("Websites", comment: "Websites label")
        static let noWebsitesAdded = L10nItem("No websites added", comment: "No websites added message")
        static let noTranscriptionModels = L10nItem("No transcription models available. Please connect to a cloud service or download a local model in the AI Models tab.", comment: "No transcription models message")
        static let emojiInUseTitle = L10nItem("Emoji in Use", comment: "Emoji in use alert title")
        static let emojiInUseMessage = L10nItem("The emoji \"%@\" is currently used by one or more Power Modes and cannot be removed.", comment: "Emoji in use alert message")
        static let emojiExists = L10nItem("Emoji already exists!", comment: "Emoji already exists feedback")
        static let emojiInvalid = L10nItem("Invalid emoji.", comment: "Invalid emoji feedback")
        static let emojiEmpty = L10nItem("Emoji cannot be empty.", comment: "Emoji empty feedback")
        static let emojiInvalidCharacter = L10nItem("Invalid emoji character.", comment: "Emoji invalid character feedback")
        static let emojiAddFailed = L10nItem("Could not add emoji.", comment: "Emoji add failed feedback")
        static let addCustomEmoji = L10nItem("Add custom emoji", comment: "Add custom emoji help text")
        static let model = L10nItem("Model", comment: "Model label")
        static let language = L10nItem("Language", comment: "Language label")
        static let autodetected = L10nItem("Autodetected", comment: "Autodetected label")
        static let aiProvider = L10nItem("AI Provider", comment: "AI provider label")
        static let noProvidersConnected = L10nItem("No providers connected", comment: "No providers connected message")
        static let aiModel = L10nItem("AI Model", comment: "AI model label")
        static let enhancementPrompt = L10nItem("Enhancement Prompt", comment: "Enhancement prompt label")

        enum Configuration {
            static let defaultName = L10nItem("New Power Mode", comment: "Default name placeholder for new power modes")
            static let deleteTitle = L10nItem("Delete Power Mode?", comment: "Delete power mode alert title")
            static let deleteMessage = L10nItem("Are you sure you want to delete the \"%@\" power mode? This action cannot be undone.", comment: "Delete power mode confirmation message")
            static let namePlaceholder = L10nItem("Name your power mode", comment: "Power mode name text field placeholder")
            static let setAsDefault = L10nItem("Set as default power mode", comment: "Toggle label to set default power mode")
            static let defaultInfoTitle = L10nItem("Default Power Mode", comment: "Default power mode info title")
            static let defaultInfoMessage = L10nItem("Default power mode is used when no specific app or website matches are found", comment: "Default power mode info message")
            static let whenToTrigger = L10nItem("When to Trigger", comment: "Section title for trigger configuration")
            static let addApp = L10nItem("Add App", comment: "Button label for adding an app trigger")
            static let websitePlaceholder = L10nItem("Enter website URL (e.g., google.com)", comment: "Website URL placeholder")
            static let transcription = L10nItem("Transcription", comment: "Transcription section title")
            static let aiEnhancement = L10nItem("AI Enhancement", comment: "AI enhancement section title")
            static let enableAIEnhancement = L10nItem("Enable AI Enhancement", comment: "Toggle label for enabling AI enhancement")
            static let advanced = L10nItem("Advanced", comment: "Advanced section title")
            static let autoSendInfoMessage = L10nItem("Automatically presses the Return/Enter key after pasting text. This is useful for chat applications or forms where its not necessary to to make changes to the transcribed text", comment: "Auto send info tip message")
            static let addNew = L10nItem("Add New Power Mode", comment: "Button label for adding a new power mode")
            static let searchApplications = L10nItem("Search applications...", comment: "Placeholder text for searching applications")
            static let singleApp = L10nItem("1 App", comment: "Single app count label")
            static let multipleApps = L10nItem("%d Apps", comment: "Multiple apps count label")
            static let singleWebsite = L10nItem("1 Website", comment: "Single website count label")
            static let multipleWebsites = L10nItem("%d Websites", comment: "Multiple websites count label")
        }

        enum Validation {
            static let nameEmpty = L10nItem("Power mode name cannot be empty.", comment: "Validation error for missing power mode name")
            static let duplicateName = L10nItem("A power mode with the name '%@' already exists.", comment: "Validation error for duplicate power mode name")
            static let duplicateApp = L10nItem("The app '%@' is already configured in the '%@' power mode.", comment: "Validation error for duplicate app trigger")
            static let duplicateWebsite = L10nItem("The website '%@' is already configured in the '%@' power mode.", comment: "Validation error for duplicate website trigger")
            static let cannotSaveTitle = L10nItem("Cannot Save Power Mode", comment: "Validation alert title")
        }
    }

    enum Transcription {
        static let original = L10nItem("Original", comment: "Original transcription tab")
        static let enhanced = L10nItem("Enhanced", comment: "Enhanced transcription tab")
        static let aiRequest = L10nItem("AI Request", comment: "AI request tab")
        static let result = L10nItem("Transcription Result", comment: "Transcription result view title")
        static let duration = L10nItem("Duration:", comment: "Duration label")
        static let systemPrompt = L10nItem("System Prompt", comment: "System prompt label")
        static let userMessage = L10nItem("User Message", comment: "User message label")
        static let powerMode = L10nItem("Power Mode", comment: "Power mode metadata label")
        static let audioDuration = L10nItem("Audio Duration", comment: "Audio duration metadata label")
        static let transcriptionModel = L10nItem("Transcription Model", comment: "Transcription model metadata label")
        static let enhancementModel = L10nItem("Enhancement Model", comment: "Enhancement model metadata label")
        static let promptUsed = L10nItem("Prompt Used", comment: "Prompt used metadata label")
        static let transcriptionTime = L10nItem("Transcription Time", comment: "Transcription time metadata label")
        static let enhancementTime = L10nItem("Enhancement Time", comment: "Enhancement time metadata label")
        static let copyEnhanced = L10nItem("Copy Enhanced", comment: "Copy enhanced text action")
        static let copyOriginal = L10nItem("Copy Original", comment: "Copy original text action")
        static let metadataUnknown = L10nItem("Unknown", comment: "Unknown metadata fallback")
    }

    enum Recorder {
        static let enhancementPrompt = L10nItem("Enhancement Prompt", comment: "Enhancement prompt toggle label")
    }

    enum Permissions {
        static let appPermissions = L10nItem("App Permissions", comment: "App permissions section title")
        static let required = L10nItem("VoiceInk requires the following permissions to function properly", comment: "Permissions requirement message")
        static let keyboardShortcut = L10nItem("Keyboard Shortcut", comment: "Keyboard shortcut permission")
        static let shortcutDescription = L10nItem("Set up a keyboard shortcut to use VoiceInk anywhere", comment: "Shortcut setup description")
        static let configureShortcut = L10nItem("Configure Shortcut", comment: "Configure shortcut button")
        static let microphoneAccess = L10nItem("Microphone Access", comment: "Microphone access permission")
        static let microphoneDescription = L10nItem("Allow VoiceInk to record your voice for transcription", comment: "Microphone permission description")
        static let requestPermission = L10nItem("Request Permission", comment: "Request permission button")
        static let openSystemSettings = L10nItem("Open System Settings", comment: "Open system settings button")
        static let accessibilityAccess = L10nItem("Accessibility Access", comment: "Accessibility access permission")
        static let accessibilityDescription = L10nItem("Allow VoiceInk to paste transcribed text directly at your cursor position", comment: "Accessibility permission description")
        static let accessibilityInfo = L10nItem("Accessibility Access Info", comment: "Accessibility info message")
        static let screenRecordingAccess = L10nItem("Screen Recording Access", comment: "Screen recording access permission")
        static let screenRecordingDescription = L10nItem("Allow VoiceInk to understand context from your screen for transcript Enhancement", comment: "Screen recording permission description")
        static let screenRecordingInfo = L10nItem("Screen Recording Access Info", comment: "Screen recording info message")
    }

    enum Enhancement {
        static let enableEnhancement = L10nItem("Enable Enhancement", comment: "Enable enhancement toggle")
        static let aiEnhancement = L10nItem("AI Enhancement", comment: "AI enhancement label")
        static let aiEnhancementHelp = L10nItem("AI enhancement lets you pass the transcribed audio through LLMS to post-process using different prompts suitable for different use cases like e-mails, summary, writing, etc.", comment: "AI enhancement help text")
        static let turnOn = L10nItem("Turn on AI-powered enhancement features", comment: "Turn on enhancement description")
        static let clipboardContext = L10nItem("Clipboard Context", comment: "Clipboard context toggle")
        static let clipboardContextHelp = L10nItem("Use text from clipboard to understand the context", comment: "Clipboard context help text")
        static let contextAwareness = L10nItem("Context Awareness", comment: "Context awareness toggle")
        static let contextAwarenessHelp = L10nItem("Learn what is on the screen to understand the context", comment: "Context awareness help text")
        static let aiProviderIntegration = L10nItem("AI Provider Integration", comment: "AI provider integration section title")
        static let enhancementPrompt = L10nItem("Enhancement Prompt", comment: "Enhancement prompt section title")
    }

    enum AIModels {
        enum Filter {
            static let recommended = L10nItem("Recommended", comment: "Recommended models filter")
            static let local = L10nItem("Local", comment: "Local models filter")
            static let cloud = L10nItem("Cloud", comment: "Cloud models filter")
            static let custom = L10nItem("Custom", comment: "Custom models filter")
        }

        static let defaultModel = L10nItem("Default Model", comment: "Default model section title")
        static let noModelSelected = L10nItem("No model selected", comment: "No model selected message")
        static let importLocalModel = L10nItem("Import Local Model…", comment: "Import local model button")
        static let delete = L10nItem("Delete", comment: "Delete button")
        static let connectedTo = L10nItem("Connected to", comment: "Connected to provider message")
        static let noModelsLoaded = L10nItem("No models loaded", comment: "No models loaded message")
        static let noModelsAvailable = L10nItem("No models available", comment: "No models available message")
        static let troubleshooting = L10nItem("Troubleshooting", comment: "Troubleshooting section")
        static let customProviderConfig = L10nItem("Custom Provider Configuration", comment: "Custom provider configuration title")
        static let openAICompatibleRequired = L10nItem("Requires OpenAI-compatible API endpoint", comment: "OpenAI compatible requirement")
        static let apiEndpointURL = L10nItem("API Endpoint URL", comment: "API endpoint URL label")
        static let model = L10nItem("Model", comment: "Model label")
        static let apiKey = L10nItem("API Key", comment: "API key label")
        static let enterAPIKey = L10nItem("Enter your API Key", comment: "Enter API key placeholder")
        static let verifyAndSave = L10nItem("Verify and Save", comment: "Verify and save button")
        static let getAPIKey = L10nItem("Get API Key", comment: "Get API key button")
        static let apiKeyConfig = L10nItem("API Key Configuration", comment: "API key configuration title")
        static let invalidAPIKey = L10nItem("Invalid API key. Please check your key and try again.", comment: "Invalid API key error")
        static let apiKeyVerified = L10nItem("API key verified successfully!", comment: "API key verified success message")
        static let configure = L10nItem("Configure", comment: "Configure button")
        static let imported = L10nItem("Imported", comment: "Imported label")
        static let importedLocalModel = L10nItem("Imported local model", comment: "Imported local model message")
        static let setAsDefault = L10nItem("Set as Default", comment: "Set as default button")
        static let optimizingModel = L10nItem("Optimizing model for your device...", comment: "Optimizing model message")
        static let experimental = L10nItem("Experimental", comment: "Experimental label")
        static let downloaded = L10nItem("Downloaded", comment: "Downloaded label")
        static let speed = L10nItem("Speed", comment: "Speed indicator")
        static let accuracy = L10nItem("Accuracy", comment: "Accuracy indicator")
        static let builtIn = L10nItem("Built-in", comment: "Built-in label")
        static let nativeApple = L10nItem("Native Apple", comment: "Native Apple label")
        static let configured = L10nItem("Configured", comment: "Configured label")
        static let setupRequired = L10nItem("Setup Required", comment: "Setup required label")
        static let transcriptionLanguage = L10nItem("Transcription Language", comment: "Transcription language label")
        static let languageAutodetected = L10nItem("Language: Autodetected", comment: "Language autodetected label")
        static let languageEnglish = L10nItem("Language: English", comment: "Language English label")
        static let languageAutodetectHelp = L10nItem("The transcription language is automatically detected by the model.", comment: "Language autodetect help text")
        static let languageEnglishOnly = L10nItem("Language: English (only)", comment: "Language English only label")
        static let currentModel = L10nItem("Current model: %@", comment: "Current model display")
        static let addModel = L10nItem("Add Model", comment: "Add model button")
        static let editModel = L10nItem("Edit Model", comment: "Edit model button")
        static let addCustomModel = L10nItem("Add Custom Model", comment: "Add custom model button")
        static let editCustomModel = L10nItem("Edit Custom Model", comment: "Edit custom model button")
        static let openAISupportedOnly = L10nItem("Only OpenAI-compatible transcription APIs are supported", comment: "OpenAI supported only message")
        static let aiProvider = L10nItem("AI Provider", comment: "AI provider label")
        static let refreshModels = L10nItem("Refresh models", comment: "Refresh models tooltip")
        static let ollamaConfiguration = L10nItem("Ollama Configuration", comment: "Ollama configuration label")
        static let checking = L10nItem("Checking...", comment: "Checking status")
        static let disconnected = L10nItem("Disconnected", comment: "Disconnected status")
        static let connected = L10nItem("Connected", comment: "Connected status")
        static let serverURL = L10nItem("Server URL", comment: "Server URL label")
        static let baseURL = L10nItem("Base URL", comment: "Base URL field label")
        static let save = L10nItem("Save", comment: "Save button")
        static let refresh = L10nItem("Refresh", comment: "Refresh button")
        static let refreshing = L10nItem("Refreshing...", comment: "Refreshing status")
        static let ollamaInstalled = L10nItem("Ensure Ollama is installed and running", comment: "Ollama installation tip")
        static let correctServerURL = L10nItem("Check if the server URL is correct", comment: "Server URL tip")
        static let modelsPulled = L10nItem("Verify you have at least one model pulled", comment: "Models pulled tip")
        static let learnMore = L10nItem("Learn More", comment: "Learn more link")
        static let apiEndpointExample = L10nItem("API Endpoint URL (e.g., https://api.example.com/v1/chat/completions)", comment: "API endpoint URL example")
        static let modelNameExample = L10nItem("Model Name (e.g., gpt-4o-mini, claude-3-5-sonnet-20240620)", comment: "Model name example")
        static let removeKey = L10nItem("Remove Key", comment: "Remove API key button")
        static let invalidAPIKeyMessage = L10nItem("Invalid API key. Please check and try again.", comment: "Invalid API key message")
        static let ollamaConnectionFailed = L10nItem("Could not connect to Ollama. Please check if Ollama is running and the base URL is correct.", comment: "Ollama connection failed message")
        static let free = L10nItem("Free", comment: "Free pricing label")
        static let paid = L10nItem("Paid", comment: "Paid pricing label")
        static let selectLanguage = L10nItem("Select Language", comment: "Select language picker")
        static let languageMenuLabel = L10nItem("Language: %@", comment: "Language menu label")
        static let multilingualModelSupport = L10nItem("This model supports multiple languages. Select a specific language or auto-detect(if available)", comment: "Multilingual model support description")
        static let englishOnlyModelSupport = L10nItem("This is an English-optimized model and only supports English transcription.", comment: "English-only model support description")
        static let cloudModel = L10nItem("Cloud Model", comment: "Cloud model label")
        static let customProvider = L10nItem("Custom Provider", comment: "Custom provider label")
        static let openAICompatible = L10nItem("OpenAI Compatible", comment: "OpenAI compatible label")
        static let removeApiKey = L10nItem("Remove API Key", comment: "Remove API key menu item")
        static let enterProviderApiKey = L10nItem("Enter your %@ API key", comment: "Prompt for entering provider API key")
        static let verify = L10nItem("Verify", comment: "Verify button label")
        static let verifying = L10nItem("Verifying...", comment: "Verifying status label")
        static let languageMultilingualShort = L10nItem("Multilingual", comment: "Short label for multilingual capability")
        static let languageEnglishOnlyShort = L10nItem("English-only", comment: "Short label for English-only capability")
        static let download = L10nItem("Download", comment: "Download button label")
        static let downloading = L10nItem("Downloading...", comment: "Downloading state label")
        static let deleteModel = L10nItem("Delete Model", comment: "Delete model menu item")
        static let showInFinder = L10nItem("Show in Finder", comment: "Show in Finder menu item")
        static let onDevice = L10nItem("On-Device", comment: "On-device label")
        static let macOSRequirement = L10nItem("macOS %d+", comment: "macOS requirement label")

        enum CustomModel {
            static let displayName = L10nItem("Display Name", comment: "Custom model display name field label")
            static let displayNamePlaceholder = L10nItem("My Custom Model", comment: "Custom model display name placeholder")
            static let apiEndpoint = L10nItem("API Endpoint", comment: "Custom model API endpoint field label")
            static let apiEndpointPlaceholder = L10nItem("https://api.example.com/v1/audio/transcriptions", comment: "Custom model API endpoint placeholder")
            static let apiKey = L10nItem("API Key", comment: "Custom model API key field label")
            static let apiKeyPlaceholder = L10nItem("your-api-key", comment: "Custom model API key placeholder")
            static let modelName = L10nItem("Model Name", comment: "Custom model model name field label")
            static let modelNamePlaceholder = L10nItem("whisper-1", comment: "Custom model model name placeholder")
            static let multilingual = L10nItem("Multilingual Model", comment: "Custom model multilingual toggle label")
            static let updateModel = L10nItem("Update Model", comment: "Update custom model button label")
            static let validationErrors = L10nItem("Validation Errors", comment: "Validation errors alert title")
            static let modelDescription = L10nItem("Custom transcription model", comment: "Custom model description")
            static let importTipTitle = L10nItem("Import local Whisper models", comment: "Info tip title for local model import")
            static let importTipMessage = L10nItem("Add a custom fine-tuned whisper model to use with VoiceInk. Select the downloaded .bin file.", comment: "Info tip message for local model import")
            static let importTipHelp = L10nItem("Read more about custom local models", comment: "Tooltip for local model import")
            static let importPanelTitle = L10nItem("Select a Whisper ggml .bin model", comment: "Title for local model import panel")

            enum Validation {
                static let emptyName = L10nItem("Name cannot be empty", comment: "Validation error when generated name is empty")
                static let emptyDisplayName = L10nItem("Display name cannot be empty", comment: "Validation error when display name is empty")
                static let emptyEndpoint = L10nItem("API endpoint cannot be empty", comment: "Validation error when API endpoint is empty")
                static let invalidEndpoint = L10nItem("API endpoint must be a valid URL", comment: "Validation error when API endpoint is invalid")
                static let emptyKey = L10nItem("API key cannot be empty", comment: "Validation error when API key is empty")
                static let emptyModelName = L10nItem("Model name cannot be empty", comment: "Validation error when model name is empty")
                static let duplicateName = L10nItem("A model with this name already exists", comment: "Validation error when name already exists")
            }
        }

        enum Alerts {
            static let deleteCustomModelTitle = L10nItem("Delete Custom Model", comment: "Alert title when deleting a custom model")
            static let deleteCustomModelMessage = L10nItem("Are you sure you want to delete the custom model '%@'?", comment: "Alert message when deleting a custom model")
            static let deleteModelTitle = L10nItem("Delete Model", comment: "Alert title when deleting a downloaded model")
            static let deleteModelMessage = L10nItem("Are you sure you want to delete the model '%@'?", comment: "Alert message when deleting a downloaded model")
        }
    }

    enum SettingsExtended {
        enum AudioCleanup {
            static let title = L10nItem("Control how VoiceInk handles your transcription data and audio recordings for privacy and storage management.", comment: "Audio cleanup settings description")
            static let immediate = L10nItem("Immediately", comment: "Immediate cleanup option")
            static let oneHour = L10nItem("1 hour", comment: "1 hour option")
            static let oneDay = L10nItem("1 day", comment: "1 day option")
            static let threeDays = L10nItem("3 days", comment: "3 days option")
            static let sevenDays = L10nItem("7 days", comment: "7 days option")
            static let fourteenDays = L10nItem("14 days", comment: "14 days option")
            static let thirtyDays = L10nItem("30 days", comment: "30 days option")
            static let retentionDescription = L10nItem("Older transcripts will be deleted automatically based on your selection.", comment: "Retention description")
            static let runCleanupNow = L10nItem("Run Transcript Cleanup Now", comment: "Run cleanup now button")
            static let cleanupTriggered = L10nItem("Cleanup triggered. Old transcripts are cleaned up according to your retention setting.", comment: "Cleanup triggered message")
            static let audioCleanupDescription = L10nItem("Audio files older than the selected period will be automatically deleted, while keeping the text transcripts intact.", comment: "Audio cleanup description")
            static let confirmCleanup = L10nItem("This will delete %d audio files older than %@.", comment: "Confirm cleanup message")
            static let totalSizeToFree = L10nItem("Total size to be freed: %@", comment: "Total size to be freed message")
            static let transcriptsPreserved = L10nItem("The text transcripts will be preserved.", comment: "Transcripts preserved message")
            static let noFilesToDelete = L10nItem("No audio files found that are older than %@.", comment: "No files to delete message")
            static let cleanupSuccess = L10nItem("Successfully deleted %d audio files. Failed to delete %d files.", comment: "Cleanup success message with errors")
            static let cleanupSuccessSimple = L10nItem("Successfully deleted %d audio files.", comment: "Cleanup success message")
            static let enableAudioCleanup = L10nItem("Enable automatic audio cleanup", comment: "Enable automatic audio cleanup toggle")
            static let keepAudioFilesFor = L10nItem("Keep audio files for", comment: "Keep audio files for picker")
            static let analyzing = L10nItem("Analyzing...", comment: "Analyzing message")
            static let audioCleanupAlertTitle = L10nItem("Audio Cleanup", comment: "Audio cleanup alert title")
            static let deleteFiles = L10nItem("Delete %d Files", comment: "Delete files button")
            static let transcriptCleanupToggle = L10nItem("Automatically delete transcript history", comment: "Transcript cleanup toggle")
            static let deleteTranscriptsOlderThan = L10nItem("Delete transcripts older than", comment: "Delete transcripts older than picker")
            static let transcriptCleanupAlertTitle = L10nItem("Transcript Cleanup", comment: "Transcript cleanup alert title")
            static let cleanupCompleteTitle = L10nItem("Cleanup Complete", comment: "Cleanup completed alert title")
            static let dayCount = L10nItem("%d day(s)", comment: "Day count label")
        }

        enum AudioInput {
            static let title = L10nItem("Audio Input", comment: "Audio input settings title")
            static let description = L10nItem("Configure your microphone preferences", comment: "Audio input description")
            static let inputMode = L10nItem("Input Mode", comment: "Input mode label")
            static let availableDevices = L10nItem("Available Devices", comment: "Available devices label")
            static let refresh = L10nItem("Refresh", comment: "Refresh button")
            static let deviceOverrideWarning = L10nItem("Note: Selecting a device here will override your Mac's system-wide default microphone.", comment: "Device override warning")
            static let prioritizedDevices = L10nItem("Prioritized Devices", comment: "Prioritized devices label")
            static let prioritizedDevicesDescription = L10nItem("Devices will be used in order of priority. If a device is unavailable, the next one will be tried. If no prioritized device is available, the system default microphone will be used.", comment: "Prioritized devices description")
            static let prioritizedDevicesWarning = L10nItem("Warning: Using a prioritized device will override your Mac's system-wide default microphone if it becomes active.", comment: "Prioritized devices warning")
            static let noPrioritizedDevices = L10nItem("No prioritized devices", comment: "No prioritized devices message")
            static let noAdditionalDevicesAvailable = L10nItem("No additional devices available", comment: "No additional devices available message")
            static let noAudioDevices = L10nItem("No Audio Devices", comment: "No audio devices message")
            static let connectDeviceToGetStarted = L10nItem("Connect an audio input device to get started", comment: "Connect device to get started")
            static let active = L10nItem("Active", comment: "Active status label")
            static let unavailable = L10nItem("Unavailable", comment: "Unavailable status label")
            
            enum Mode {
                static let systemDefault = L10nItem("System Default", comment: "System default input mode")
                static let custom = L10nItem("Custom Device", comment: "Custom device input mode")
                static let prioritized = L10nItem("Prioritized", comment: "Prioritized input mode")
                static let systemDefaultDescription = L10nItem("Use system's default input device", comment: "System default mode description")
                static let customDescription = L10nItem("Select a specific input device", comment: "Custom mode description")
                static let prioritizedDescription = L10nItem("Set up device priority order", comment: "Prioritized mode description")
            }
        }

        enum EnhancementShortcuts {
            static let title = L10nItem("Enhancement Shortcuts", comment: "Enhancement shortcuts title")
            static let description = L10nItem("Keep enhancement prompts handy", comment: "Enhancement shortcuts description")
            static let availabilityNote = L10nItem("Enhancement shortcuts are available only when the recorder is visible and VoiceInk is running.", comment: "Shortcuts availability note")
            static let toggleTitle = L10nItem("Toggle AI Enhancement", comment: "Toggle AI enhancement shortcut title")
            static let toggleDescription = L10nItem("Quickly enable or disable enhancement while recording.", comment: "Toggle enhancement description")
            static let switchTitle = L10nItem("Switch Enhancement Prompt", comment: "Switch enhancement prompt shortcut title")
            static let switchDescription = L10nItem("Switch between your saved prompts without touching the UI. Use ⌘1–⌘0 to activate the corresponding prompt in the order they are saved.", comment: "Switch prompt description")
        }

        enum ExperimentalFeatures {
            static let title = L10nItem("Experimental Features", comment: "Experimental features title")
            static let description = L10nItem("Experimental features that might be unstable & bit buggy.", comment: "Experimental features description")
            static let toggleLabel = L10nItem("Experimental Features", comment: "Experimental features toggle")
            static let pauseMedia = L10nItem("Pause Media during recording", comment: "Pause media during recording")
            static let pauseMediaHelp = L10nItem("Automatically pause active media playback during recordings and resume afterward.", comment: "Pause media help text")
        }

        enum ModelSettings {
            static let outputFormat = L10nItem("Output Format", comment: "Output format label")
            static let addSpaceAfterPaste = L10nItem("Add space after paste", comment: "Add space after paste label")
            static let automaticTextFormatting = L10nItem("Automatic text formatting", comment: "Automatic text formatting label")
            static let voiceActivityDetection = L10nItem("Voice Activity Detection (VAD)", comment: "Voice activity detection label")
            static let outputFormatGuideTitle = L10nItem("Output Format Guide", comment: "Output format info title")
            static let outputFormatGuideMessage = L10nItem("Unlike GPT, Voice Models (Whisper) follows the style of your prompt rather than instructions. Use examples of your desired output format instead of commands.", comment: "Output format info message")
            static let trailingSpaceTitle = L10nItem("Trailing Space", comment: "Trailing space info title")
            static let trailingSpaceMessage = L10nItem("Automatically add a space after pasted text. Useful for space-delimited languages.", comment: "Trailing space info message")
            static let textFormattingTitle = L10nItem("Automatic Text Formatting", comment: "Automatic text formatting info title")
            static let textFormattingMessage = L10nItem("Apply intelligent text formatting to break large blocks of text into paragraphs.", comment: "Automatic text formatting info message")
            static let vadTitle = L10nItem("Voice Activity Detection", comment: "VAD info title")
            static let vadMessage = L10nItem("Detect speech segments and filter out silence to improve accuracy of local models.", comment: "VAD info message")
        }
    }

    enum DictionaryExtended {
        enum WordReplacement {
            static let title = L10nItem("Define word replacements to automatically replace specific words or phrases", comment: "Word replacement title")
            static let original = L10nItem("Original", comment: "Original text label")
            static let replacement = L10nItem("Replacement", comment: "Replacement text label")
            static let noReplacements = L10nItem("No Replacements", comment: "No replacements message")
            static let addDescription = L10nItem("Add word replacements to automatically replace text.", comment: "Add replacement description")
            static let add = L10nItem("Add Word Replacement", comment: "Add word replacement button")
            static let defineOriginal = L10nItem("Define a word or phrase to be automatically replaced.", comment: "Define original text description")
            static let required = L10nItem("Required", comment: "Required field label")
            static let separateExamples = L10nItem("Separate multiple originals with commas, e.g. Voicing, Voice ink, Voiceing", comment: "Separate examples text")
            static let examples = L10nItem("Examples", comment: "Examples label")
            static let edit = L10nItem("Edit Word Replacement", comment: "Edit word replacement title")
            static let updateDescription = L10nItem("Update the word or phrase that should be automatically replaced.", comment: "Update replacement description")
            static let originalText = L10nItem("Original Text", comment: "Original text field label")
            static let replacementText = L10nItem("Replacement Text", comment: "Replacement text field label")
            static let enterPlaceholder = L10nItem("Enter word or phrase to replace (use commas for multiple)", comment: "Enter placeholder text")
            static let removeWord = L10nItem("Remove word", comment: "Remove word tooltip")
            static let editReplacement = L10nItem("Edit replacement", comment: "Edit replacement tooltip")
            static let removeReplacement = L10nItem("Remove replacement", comment: "Remove replacement tooltip")
            static let enable = L10nItem("Enable", comment: "Enable toggle label")
            static let websiteLinkExample = L10nItem("my website link", comment: "Website link example")
            static let enableDescription = L10nItem("Enable automatic word replacement after transcription", comment: "Enable description")
            static let save = L10nItem("Save", comment: "Save button")
            static let `continue` = L10nItem("Continue", comment: "Continue button")
            static let exampleLinkValue = L10nItem("https://tryvoiceink.com", comment: "Example replacement link")
            static let exampleOriginalsValue = L10nItem("Voicing, Voice ink, Voiceing", comment: "Example comma separated originals")
            static let exampleReplacementValue = L10nItem("VoiceInk", comment: "Example replacement value")
        }
    }

    enum Components {
        static let noPromptsAvailable = L10nItem("No prompts available", comment: "No prompts available message")
        static let editHint = L10nItem("Double-click to edit • Right-click for more options", comment: "Edit hint text")
        static let beforeCopy = L10nItem("Before Copy", comment: "Before copy preview text")
        static let saveButtonPreview = L10nItem("Save Button Preview", comment: "Save button preview text")
        static let learnMore = L10nItem("Learn More", comment: "Learn more link text")
        static let saveAsTXT = L10nItem("Save as TXT", comment: "Save as TXT menu item")
        static let saveAsMD = L10nItem("Save as MD", comment: "Save as MD menu item")
        static let save = L10nItem("Save", comment: "Save button")
        static let saved = L10nItem("Saved", comment: "Saved button state")
        static let saveTranscription = L10nItem("Save Transcription", comment: "Save transcription panel title")
        static let copy = L10nItem("Copy", comment: "Copy button")
        static let copied = L10nItem("Copied", comment: "Copied button state")
        static let addNewPrompt = L10nItem("Add new prompt", comment: "Add new prompt tooltip")
    }

    enum Metrics {
        static let noTranscriptionsYet = L10nItem("No Transcriptions Yet", comment: "No transcriptions yet message")
        static let startFirstRecording = L10nItem("Start your first recording to unlock value insights.", comment: "Start first recording message")
        static let savedWithVoiceInk = L10nItem("You have saved %@ with VoiceInk", comment: "Saved time prefix")
        static let withVoiceInk = L10nItem(" with VoiceInk", comment: "With VoiceInk suffix")
        static let welcomeToVoiceInk = L10nItem("Welcome to VoiceInk", comment: "Welcome message")
        static let completeSetup = L10nItem("Complete the setup to get started", comment: "Complete setup message")
        static let needHelp = L10nItem("Need help? Check the Help menu for support options", comment: "Need help message")
        static let performanceAnalysis = L10nItem("Performance Analysis", comment: "Performance analysis title")
        static let systemInformation = L10nItem("System Information", comment: "System information title")
        static let transcriptionModels = L10nItem("Transcription Models", comment: "Transcription models title")
        static let enhancementModels = L10nItem("Enhancement Models", comment: "Enhancement models title")
        static let transcripts = L10nItem("%@ transcripts", comment: "Transcripts count")
        static let fasterThanRealTime = L10nItem("Faster than Real-time", comment: "Faster than real-time label")
        static let avgEnhancementTime = L10nItem("Avg. Enhancement Time", comment: "Average enhancement time label")
        static let helpAndResources = L10nItem("Help & Resources", comment: "Help and resources title")
        static let voiceInk = L10nItem("VoiceInk", comment: "VoiceInk app name")
        static let sessionsRecorded = L10nItem("Sessions Recorded", comment: "Sessions recorded metric")
        static let sessionsCompleted = L10nItem("VoiceInk sessions completed", comment: "Sessions completed detail")
        static let wordsDictated = L10nItem("Words Dictated", comment: "Words dictated metric")
        static let wordsGenerated = L10nItem("words generated", comment: "Words generated detail")
        static let wordsPerMinute = L10nItem("Words Per Minute", comment: "Words per minute metric")
        static let vsTyping = L10nItem("VoiceInk vs. typing by hand", comment: "WPM comparison detail")
        static let keystrokesSaved = L10nItem("Keystrokes Saved", comment: "Keystrokes saved metric")
        static let fewerKeystrokes = L10nItem("fewer keystrokes", comment: "Fewer keystrokes detail")
        static let journeyStarts = L10nItem("Your VoiceInk journey starts with your first recording.", comment: "Journey starts message")
        static let sessionSingular = L10nItem("session", comment: "Singular session")
        static let sessionPlural = L10nItem("sessions", comment: "Plural sessions")
        static let dictatedFormat = L10nItem("Dictated %@ words across %d %@.", comment: "Dictated words format")
        static let timeSavingsComing = L10nItem("Time savings coming soon", comment: "Time savings coming soon fallback")
        static let feedbackOrIssues = L10nItem("Feedback or Issues?", comment: "Feedback or issues button")
        static let sending = L10nItem("Sending", comment: "Sending status")
        static let copySystemInfo = L10nItem("Copy System Info", comment: "Copy system info button")
        static let copied = L10nItem("Copied!", comment: "Copied status")
        
        enum Promotions {
            static let upgradeBadge = L10nItem("30% OFF", comment: "Upgrade promotion badge")
            static let upgradeTitle = L10nItem("Unlock VoiceInk Pro For Less", comment: "Upgrade promotion title")
            static let upgradeMessage = L10nItem("Share VoiceInk on your socials, and instantly unlock a 30% discount on VoiceInk Pro.", comment: "Upgrade promotion message")
            static let upgradeAction = L10nItem("Share & Unlock", comment: "Upgrade promotion action title")
            static let affiliateBadge = L10nItem("AFFILIATE 30%", comment: "Affiliate promotion badge")
            static let affiliateTitle = L10nItem("Earn With The VoiceInk Affiliate Program", comment: "Affiliate promotion title")
            static let affiliateMessage = L10nItem("Share VoiceInk with friends or your audience and receive 30% on every referral that upgrades.", comment: "Affiliate promotion message")
            static let affiliateAction = L10nItem("Explore Affiliate", comment: "Affiliate promotion action title")
        }
        
        enum Help {
            static let recommendedModels = L10nItem("Recommended Models", comment: "Recommended models resource title")
            static let youtubeGuides = L10nItem("YouTube Videos & Guides", comment: "YouTube videos resource title")
            static let documentation = L10nItem("Documentation", comment: "Documentation resource title")
        }
        
        enum Setup {
            static let setShortcutTitle = L10nItem("Set Keyboard Shortcut", comment: "Setup step: keyboard shortcut title")
            static let setShortcutDescription = L10nItem("Use VoiceInk anywhere with a shortcut.", comment: "Setup step: keyboard shortcut description")
            static let accessibilityTitle = L10nItem("Enable Accessibility", comment: "Setup step: accessibility title")
            static let accessibilityDescription = L10nItem("Paste transcribed text at your cursor.", comment: "Setup step: accessibility description")
            static let screenRecordingTitle = L10nItem("Enable Screen Recording", comment: "Setup step: screen recording title")
            static let screenRecordingDescription = L10nItem("Get better transcriptions with screen context.", comment: "Setup step: screen recording description")
            static let downloadModelTitle = L10nItem("Download Model", comment: "Setup step: download model title")
            static let downloadModelDescription = L10nItem("Choose an AI model to start transcribing.", comment: "Setup step: download model description")
            static let configureShortcut = L10nItem("Configure Shortcut", comment: "Action button: configure shortcut")
            static let enableAccessibilityAction = L10nItem("Enable Accessibility", comment: "Action button: enable accessibility")
            static let enableScreenRecordingAction = L10nItem("Enable Screen Recording", comment: "Action button: enable screen recording")
            static let downloadModelAction = L10nItem("Download Model", comment: "Action button: download model")
            static let getStarted = L10nItem("Get Started", comment: "Action button: get started")
        }
        
        enum Performance {
            static let totalTranscripts = L10nItem("Total Transcripts", comment: "Total transcripts label")
            static let analyzable = L10nItem("Analyzable", comment: "Analyzable transcripts label")
            static let enhanced = L10nItem("Enhanced", comment: "Enhanced transcripts label")
            static let device = L10nItem("Device", comment: "System info: device label")
            static let processor = L10nItem("Processor", comment: "System info: processor label")
            static let memory = L10nItem("Memory", comment: "System info: memory label")
            static let avgAudio = L10nItem("Avg. Audio", comment: "Average audio duration label")
            static let avgProcessTime = L10nItem("Avg. Process Time", comment: "Average processing time label")
            static let secondsFormat = L10nItem("%.2f s", comment: "Seconds duration format")
            static let speedFactorFormat = L10nItem("%.1fx", comment: "Speed factor format")
            static let zeroSeconds = L10nItem("0s", comment: "Zero seconds fallback")
        }
        
        enum TimeEfficiency {
            static let youAre = L10nItem("You are", comment: "Time efficiency header prefix")
            static let fasterFormat = L10nItem("%@ Faster", comment: "Time efficiency faster format")
            static let withVoiceInk = L10nItem("with VoiceInk", comment: "Time efficiency suffix")
            static let speakingTime = L10nItem("SPEAKING TIME", comment: "Speaking time label")
            static let typingTime = L10nItem("TYPING TIME", comment: "Typing time label")
            static let timeSaved = L10nItem("TIME SAVED", comment: "Time saved label")
            static let report = L10nItem("Report", comment: "Report button title")
        }
    }

    enum History {
        static let noTranscriptionsFound = L10nItem("No transcriptions found", comment: "No transcriptions found message")
        static let yourHistoryWillAppearHere = L10nItem("Your history will appear here", comment: "Your history will appear here message")
        static let deleteConfirmationMessage = L10nItem("This action cannot be undone. Are you sure you want to delete %d item%@?", comment: "Delete confirmation message")
        static let selectedCount = L10nItem("%d selected", comment: "Selected count format")
        static let searchTranscriptions = L10nItem("Search transcriptions", comment: "Search field placeholder")
        static let selectAll = L10nItem("Select All", comment: "Select all button")
        static let deselectAll = L10nItem("Deselect All", comment: "Deselect all button")
        static let deleteSelectedItems = L10nItem("Delete Selected Items?", comment: "Delete selected items confirmation")
        static let loading = L10nItem("Loading...", comment: "Loading text")
        static let loadMore = L10nItem("Load More", comment: "Load more button")
    }

    enum TranscribeAudio {
        static let error = L10nItem("Error", comment: "Error alert title")
        static let audioFileSelected = L10nItem("Audio file selected: %@", comment: "Audio file selected message")
        static let promptLabel = L10nItem("Prompt:", comment: "Prompt label")
        static let startTranscription = L10nItem("Start Transcription", comment: "Start transcription button")
        static let chooseDifferentFile = L10nItem("Choose Different File", comment: "Choose different file button")
        static let dropAudioOrVideo = L10nItem("Drop audio or video file here", comment: "Drop zone message")
        static let or = L10nItem("or", comment: "Or separator")
        static let chooseFile = L10nItem("Choose File", comment: "Choose file button")
        static let supportedFormats = L10nItem("Supported formats: WAV, MP3, M4A, AIFF, MP4, MOV", comment: "Supported formats message")
        static let enhancing = L10nItem("Enhancing", comment: "Enhancing status")
        static let transcribing = L10nItem("Transcribing", comment: "Transcribing status")
    }

    enum AudioPlayer {
        static let generatingWaveform = L10nItem("Generating waveform...", comment: "Generating waveform status")
        static let recording = L10nItem("Recording", comment: "Recording status")
        static let retranscriptionSuccessful = L10nItem("Retranscription successful", comment: "Retranscription success message")
        static let retranscriptionFailed = L10nItem("Retranscription failed", comment: "Retranscription failed message")
        static let retranscribeHint = L10nItem("Retranscribe this audio", comment: "Retranscribe tooltip")
        static let noModelSelected = L10nItem("No transcription model selected", comment: "No transcription model selected error")
    }
}
