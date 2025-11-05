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

    enum License {
        static let upgradeToPro = L10nItem("Upgrade to Pro", comment: "Upsell heading for upgrading to Pro")
        static let versionFormat = L10nItem("v%@", comment: "Displayed app version with leading v")
        static let supportMessage = L10nItem("Thank you for supporting VoiceInk", comment: "Message shown to licensed users")
        static let heroSubtitle = L10nItem("Transcribe what you say to text instantly with AI", comment: "Subtitle encouraging upgrade")

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

        static let licenseActive = L10nItem("License Active", comment: "Heading shown when license is active")
        static let activeStatus = L10nItem("Active", comment: "Tag indicating active status")
        static let activationLimitMessage = L10nItem("This license can be activated on up to %d devices", comment: "Message showing device activation limit")
        static let allDevicesMessage = L10nItem("You can use VoiceInk Pro on all your personal devices", comment: "Message indicating unlimited device usage")

        static let licenseManagement = L10nItem("License Management", comment: "Section header for managing license")
        static let deactivateLicense = L10nItem("Deactivate License", comment: "Action label to deactivate license")
    }
}
