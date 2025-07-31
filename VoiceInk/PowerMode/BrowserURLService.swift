import Foundation
import AppKit
import os

enum BrowserType {
    case safari
    case arc
    case chrome
    case edge
    case firefox
    case brave
    case opera
    case vivaldi
    case orion
    case zen
    case yandex
    
    var scriptName: String {
        switch self {
        case .safari: return NSLocalizedString(NSLocalizedString("safariURL", comment: "safariURL"), comment: "safariURL")
        case .arc: return NSLocalizedString(NSLocalizedString("arcURL", comment: "arcURL"), comment: "arcURL")
        case .chrome: return NSLocalizedString(NSLocalizedString("chromeURL", comment: "chromeURL"), comment: "chromeURL")
        case .edge: return NSLocalizedString(NSLocalizedString("edgeURL", comment: "edgeURL"), comment: "edgeURL")
        case .firefox: return NSLocalizedString(NSLocalizedString("firefoxURL", comment: "firefoxURL"), comment: "firefoxURL")
        case .brave: return NSLocalizedString(NSLocalizedString("braveURL", comment: "braveURL"), comment: "braveURL")
        case .opera: return NSLocalizedString(NSLocalizedString("operaURL", comment: "operaURL"), comment: "operaURL")
        case .vivaldi: return NSLocalizedString(NSLocalizedString("vivaldiURL", comment: "vivaldiURL"), comment: "vivaldiURL")
        case .orion: return NSLocalizedString(NSLocalizedString("orionURL", comment: "orionURL"), comment: "orionURL")
        case .zen: return NSLocalizedString(NSLocalizedString("zenURL", comment: "zenURL"), comment: "zenURL")
        case .yandex: return NSLocalizedString(NSLocalizedString("yandexURL", comment: "yandexURL"), comment: "yandexURL")
        }
    }
    
    var bundleIdentifier: String {
        switch self {
        case .safari: return "com.apple.Safari"
        case .arc: return "company.thebrowser.Browser"
        case .chrome: return "com.google.Chrome"
        case .edge: return "com.microsoft.edgemac"
        case .firefox: return "org.mozilla.firefox"
        case .brave: return "com.brave.Browser"
        case .opera: return "com.operasoftware.Opera"
        case .vivaldi: return "com.vivaldi.Vivaldi"
        case .orion: return "com.kagi.kagimacOS"
        case .zen: return "app.zen-browser.zen"
        case .yandex: return "ru.yandex.desktop.yandex-browser"
        }
    }
    
    var displayName: String {
        switch self {
        case .safari: return NSLocalizedString(NSLocalizedString("Safari", comment: "Safari"), comment: "Safari")
        case .arc: return NSLocalizedString(NSLocalizedString("Arc", comment: "Arc"), comment: "Arc")
        case .chrome: return NSLocalizedString(NSLocalizedString("Google Chrome", comment: "Google Chrome"), comment: "Google Chrome")
        case .edge: return NSLocalizedString(NSLocalizedString("Microsoft Edge", comment: "Microsoft Edge"), comment: "Microsoft Edge")
        case .firefox: return NSLocalizedString(NSLocalizedString("Firefox", comment: "Firefox"), comment: "Firefox")
        case .brave: return NSLocalizedString(NSLocalizedString("Brave", comment: "Brave"), comment: "Brave")
        case .opera: return NSLocalizedString(NSLocalizedString("Opera", comment: "Opera"), comment: "Opera")
        case .vivaldi: return NSLocalizedString(NSLocalizedString("Vivaldi", comment: "Vivaldi"), comment: "Vivaldi")
        case .orion: return NSLocalizedString(NSLocalizedString("Orion", comment: "Orion"), comment: "Orion")
        case .zen: return NSLocalizedString(NSLocalizedString("Zen Browser", comment: "Zen Browser"), comment: "Zen Browser")
        case .yandex: return NSLocalizedString(NSLocalizedString("Yandex Browser", comment: "Yandex Browser"), comment: "Yandex Browser")
        }
    }
    
    static var allCases: [BrowserType] {
        [.safari, .arc, .chrome, .edge, .brave, .opera, .vivaldi, .orion, .yandex]
    }
    
    static var installedBrowsers: [BrowserType] {
        allCases.filter { browser in
            let workspace = NSWorkspace.shared
            return workspace.urlForApplication(withBundleIdentifier: browser.bundleIdentifier) != nil
        }
    }
}

enum BrowserURLError: Error {
    case scriptNotFound
    case executionFailed
    case browserNotRunning
    case noActiveWindow
    case noActiveTab
}

class BrowserURLService {
    static let shared = BrowserURLService()
    
    private let logger = Logger(
        subsystem: "com.prakashjoshipax.VoiceInk",
        category: "browser.applescript"
    )
    
    private init() {}
    
    func getCurrentURL(from browser: BrowserType) async throws -> String {
        guard let scriptURL = Bundle.main.url(forResource: browser.scriptName, withExtension: "scpt") else {
            logger.error("❌ AppleScript file not found: \(browser.scriptName).scpt")
            throw BrowserURLError.scriptNotFound
        }
        
        logger.debug("🔍 Attempting to execute AppleScript for \(browser.displayName)")
        
        // Check if browser is running
        if !isRunning(browser) {
            logger.error("❌ Browser not running: \(browser.displayName)")
            throw BrowserURLError.browserNotRunning
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptURL.path]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            logger.debug("▶️ Executing AppleScript for \(browser.displayName)")
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if output.isEmpty {
                    logger.error("❌ Empty output from AppleScript for \(browser.displayName)")
                    throw BrowserURLError.noActiveTab
                }
                
                // Check if output contains error messages
                if output.lowercased().contains("error") {
                    logger.error("❌ AppleScript error for \(browser.displayName): \(output)")
                    throw BrowserURLError.executionFailed
                }
                
                logger.debug("✅ Successfully retrieved URL from \(browser.displayName): \(output)")
                return output
            } else {
                logger.error("❌ Failed to decode output from AppleScript for \(browser.displayName)")
                throw BrowserURLError.executionFailed
            }
        } catch {
            logger.error("❌ AppleScript execution failed for \(browser.displayName): \(error.localizedDescription)")
            throw BrowserURLError.executionFailed
        }
    }
    
    func isRunning(_ browser: BrowserType) -> Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        let isRunning = runningApps.contains { $0.bundleIdentifier == browser.bundleIdentifier }
        logger.debug("\(browser.displayName) running status: \(isRunning)")
        return isRunning
    }
} 
