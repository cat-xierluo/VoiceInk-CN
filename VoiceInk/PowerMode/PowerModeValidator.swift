import Foundation
import SwiftUI

enum PowerModeValidationError: Error, Identifiable {
    case emptyName
    case duplicateName(String)
<<<<<<< HEAD
    case noTriggers
=======
>>>>>>> upstream/main
    case duplicateAppTrigger(String, String) // (app name, existing power mode name)
    case duplicateWebsiteTrigger(String, String) // (website, existing power mode name)
    
    var id: String {
        switch self {
<<<<<<< HEAD
        case .emptyName: return NSLocalizedString(NSLocalizedString("emptyName", comment: "emptyName"), comment: "emptyName")
        case .duplicateName: return NSLocalizedString(NSLocalizedString("duplicateName", comment: "duplicateName"), comment: "duplicateName")
        case .noTriggers: return NSLocalizedString(NSLocalizedString("noTriggers", comment: "noTriggers"), comment: "noTriggers")
        case .duplicateAppTrigger: return NSLocalizedString(NSLocalizedString("duplicateAppTrigger", comment: "duplicateAppTrigger"), comment: "duplicateAppTrigger")
        case .duplicateWebsiteTrigger: return NSLocalizedString(NSLocalizedString("duplicateWebsiteTrigger", comment: "duplicateWebsiteTrigger"), comment: "duplicateWebsiteTrigger")
=======
        case .emptyName: return "emptyName"
        case .duplicateName: return "duplicateName"
        case .duplicateAppTrigger: return "duplicateAppTrigger"
        case .duplicateWebsiteTrigger: return "duplicateWebsiteTrigger"
>>>>>>> upstream/main
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .emptyName:
<<<<<<< HEAD
return NSLocalizedString("Power mode name cannot be empty.", comment: "Power mode name cannot be empty.")
        case .duplicateName(let name):
            return NSLocalizedString("A power mode with the name '\(name)' already exists.", comment: "A power mode with the name '\(name)' already exists.")
        case .noTriggers:
return NSLocalizedString("You must add at least one application or website.", comment: "You must add at least one application or website.")
        case .duplicateAppTrigger(let appName, let powerModeName):
            return NSLocalizedString("The app '\(appName)' is already configured in the '\(powerModeName)' power mode.", comment: "The app '\(appName)' is already configured in the '\(powerModeName)' power mode.")
        case .duplicateWebsiteTrigger(let website, let powerModeName):
            return NSLocalizedString("The website '\(website)' is already configured in the '\(powerModeName)' power mode.", comment: "The website '\(website)' is already configured in the '\(powerModeName)' power mode.")
=======
            return "Power mode name cannot be empty."
        case .duplicateName(let name):
            return "A power mode with the name '\(name)' already exists."
        case .duplicateAppTrigger(let appName, let powerModeName):
            return "The app '\(appName)' is already configured in the '\(powerModeName)' power mode."
        case .duplicateWebsiteTrigger(let website, let powerModeName):
            return "The website '\(website)' is already configured in the '\(powerModeName)' power mode."
>>>>>>> upstream/main
        }
    }
}

struct PowerModeValidator {
    private let powerModeManager: PowerModeManager
    
    init(powerModeManager: PowerModeManager) {
        self.powerModeManager = powerModeManager
    }
    
<<<<<<< HEAD
    /// Validates a power mode configuration when the user tries to save it.
    /// This validation only happens at save time, not during editing.
    func validateForSave(config: PowerModeConfig, mode: ConfigurationMode) -> [PowerModeValidationError] {
        var errors: [PowerModeValidationError] = []
        
        // Validate name
=======
    func validateForSave(config: PowerModeConfig, mode: ConfigurationMode) -> [PowerModeValidationError] {
        var errors: [PowerModeValidationError] = []
        
>>>>>>> upstream/main
        if config.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
        }
        
<<<<<<< HEAD
        // Check for duplicate name
        let isDuplicateName = powerModeManager.configurations.contains { existingConfig in
            if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
                // Skip checking against itself when editing
=======
        let isDuplicateName = powerModeManager.configurations.contains { existingConfig in
            if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
>>>>>>> upstream/main
                return false
            }
            return existingConfig.name == config.name
        }
        
        if isDuplicateName {
            errors.append(.duplicateName(config.name))
        }
        
<<<<<<< HEAD
        // For non-default modes, check that there's at least one trigger
        if !mode.isEditingDefault {
            if (config.appConfigs == nil || config.appConfigs?.isEmpty == true) && 
               (config.urlConfigs == nil || config.urlConfigs?.isEmpty == true) {
                errors.append(.noTriggers)
            }
            
            // Check for duplicate app configurations
            if let appConfigs = config.appConfigs {
                for appConfig in appConfigs {
                    for existingConfig in powerModeManager.configurations {
                        // Skip checking against itself when editing
                        if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
                            continue
                        }
                        
                        if let existingAppConfigs = existingConfig.appConfigs,
                           existingAppConfigs.contains(where: { $0.bundleIdentifier == appConfig.bundleIdentifier }) {
                            errors.append(.duplicateAppTrigger(appConfig.appName, existingConfig.name))
                        }
                    }
                }
            }
            
            // Check for duplicate website configurations
            if let urlConfigs = config.urlConfigs {
                for urlConfig in urlConfigs {
                    for existingConfig in powerModeManager.configurations {
                        // Skip checking against itself when editing
                        if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
                            continue
                        }
                        
                        if let existingUrlConfigs = existingConfig.urlConfigs,
                           existingUrlConfigs.contains(where: { $0.url == urlConfig.url }) {
                            errors.append(.duplicateWebsiteTrigger(urlConfig.url, existingConfig.name))
                        }
=======

        
        if let appConfigs = config.appConfigs {
            for appConfig in appConfigs {
                for existingConfig in powerModeManager.configurations {
                    if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
                        continue
                    }
                    
                    if let existingAppConfigs = existingConfig.appConfigs,
                       existingAppConfigs.contains(where: { $0.bundleIdentifier == appConfig.bundleIdentifier }) {
                        errors.append(.duplicateAppTrigger(appConfig.appName, existingConfig.name))
                    }
                }
            }
        }
        
        if let urlConfigs = config.urlConfigs {
            for urlConfig in urlConfigs {
                for existingConfig in powerModeManager.configurations {
                    if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
                        continue
                    }
                    
                    if let existingUrlConfigs = existingConfig.urlConfigs,
                       existingUrlConfigs.contains(where: { $0.url == urlConfig.url }) {
                        errors.append(.duplicateWebsiteTrigger(urlConfig.url, existingConfig.name))
>>>>>>> upstream/main
                    }
                }
            }
        }
        
        return errors
    }
}

<<<<<<< HEAD
// Alert extension for showing validation errors
=======
>>>>>>> upstream/main
extension View {
    func powerModeValidationAlert(
        errors: [PowerModeValidationError],
        isPresented: Binding<Bool>
    ) -> some View {
        self.alert(
<<<<<<< HEAD
NSLocalizedString("Cannot Save Power Mode", comment: "Cannot Save Power Mode"),
=======
            "Cannot Save Power Mode", 
>>>>>>> upstream/main
            isPresented: isPresented,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                if let firstError = errors.first {
                    Text(firstError.localizedDescription)
                } else {
<<<<<<< HEAD
                    Text(NSLocalizedString("Please fix the validation errors before saving.", comment: "Please fix the validation errors before saving."))
=======
                    Text("Please fix the validation errors before saving.")
>>>>>>> upstream/main
                }
            }
        )
    }
} 