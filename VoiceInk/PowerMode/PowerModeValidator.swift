import Foundation
import SwiftUI

enum PowerModeValidationError: Error, Identifiable {
    case emptyName
    case duplicateName(String)
    case noTriggers
    case duplicateAppTrigger(String, String) // (app name, existing power mode name)
    case duplicateWebsiteTrigger(String, String) // (website, existing power mode name)
    
    var id: String {
        switch self {
        case .emptyName: return "emptyName"
        case .duplicateName: return "duplicateName"
        case .noTriggers: return "noTriggers"
        case .duplicateAppTrigger: return "duplicateAppTrigger"
        case .duplicateWebsiteTrigger: return "duplicateWebsiteTrigger"
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .emptyName:
            return NSLocalizedString("Power mode name cannot be empty.", comment: "Error message when power mode name is empty")
        case .duplicateName(let name):
            let prefix = NSLocalizedString("A power mode with the name", comment: "Error message prefix for duplicate name")
            let suffix = NSLocalizedString("already exists.", comment: "Error message suffix for duplicate name")
            return "\(prefix) \(name) \(suffix)"
        case .noTriggers:
            return NSLocalizedString("You must add at least one application or website.", comment: "Error message when no triggers are added")
        case .duplicateAppTrigger(let appName, let powerModeName):
            let prefix = NSLocalizedString("The app", comment: "Error message prefix for duplicate app")
            let middle = NSLocalizedString("is already configured in the", comment: "Error message middle for duplicate app")
            let suffix = NSLocalizedString("power mode.", comment: "Error message suffix for duplicate app")
            return "\(prefix) \(appName) \(middle) \(powerModeName) \(suffix)"
        case .duplicateWebsiteTrigger(let website, let powerModeName):
            let prefix = NSLocalizedString("The website", comment: "Error message prefix for duplicate website")
            let middle = NSLocalizedString("is already configured in the", comment: "Error message middle for duplicate website")
            let suffix = NSLocalizedString("power mode.", comment: "Error message suffix for duplicate website")
            return "\(prefix) \(website) \(middle) \(powerModeName) \(suffix)"
        }
    }
}

struct PowerModeValidator {
    private let powerModeManager: PowerModeManager
    
    init(powerModeManager: PowerModeManager) {
        self.powerModeManager = powerModeManager
    }
    
    /// Validates a power mode configuration when the user tries to save it.
    /// This validation only happens at save time, not during editing.
    func validateForSave(config: PowerModeConfig, mode: ConfigurationMode) -> [PowerModeValidationError] {
        var errors: [PowerModeValidationError] = []
        
        // Validate name
        if config.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
        }
        
        // Check for duplicate name
        let isDuplicateName = powerModeManager.configurations.contains { existingConfig in
            if case .edit(let editConfig) = mode, existingConfig.id == editConfig.id {
                // Skip checking against itself when editing
                return false
            }
            return existingConfig.name == config.name
        }
        
        if isDuplicateName {
            errors.append(.duplicateName(config.name))
        }
        
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
                    }
                }
            }
        }
        
        return errors
    }
}

// Alert extension for showing validation errors
extension View {
    func powerModeValidationAlert(
        errors: [PowerModeValidationError],
        isPresented: Binding<Bool>
    ) -> some View {
        self.alert(
            "Cannot Save Power Mode", 
            isPresented: isPresented,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                if let firstError = errors.first {
                    Text(firstError.localizedDescription)
                } else {
                    Text("Please fix the validation errors before saving.")
                }
            }
        )
    }
} 
