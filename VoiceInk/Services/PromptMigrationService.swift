import Foundation
import os

class PromptMigrationService {
    private let logger = Logger(
        subsystem: "com.prakashjoshipax.VoiceInk",
        category: "migration"
    )
    
    private static let migrationVersionKey = "PromptMigrationVersion"
    private static let currentMigrationVersion = 1
    
    // Legacy CustomPrompt structure for migration
    private struct LegacyCustomPrompt: Codable {
        let id: UUID
        let title: String
        let promptText: String
        var isActive: Bool
        let icon: PromptIcon
        let description: String?
        let isPredefined: Bool
        let triggerWord: String?
    }
    
    static func migratePromptsIfNeeded() -> [CustomPrompt] {
        let currentVersion = UserDefaults.standard.integer(forKey: migrationVersionKey)
        
        if currentVersion < currentMigrationVersion {
            let logger = Logger(subsystem: "com.prakashjoshipax.VoiceInk", category: "migration")
            logger.notice("Starting prompt migration from version \(currentVersion) to \(currentMigrationVersion)")
            
            let migratedPrompts = migrateLegacyPrompts()
            
            // Update migration version
            UserDefaults.standard.set(currentMigrationVersion, forKey: migrationVersionKey)
            
            logger.notice("Prompt migration completed successfully. Migrated \(migratedPrompts.count) prompts")
            return migratedPrompts
        }
        
        // No migration needed, load current format
        if let savedPromptsData = UserDefaults.standard.data(forKey: "customPrompts"),
           let decodedPrompts = try? JSONDecoder().decode([CustomPrompt].self, from: savedPromptsData) {
            return decodedPrompts
        }
        
        return []
    }
    
    private static func migrateLegacyPrompts() -> [CustomPrompt] {
        let logger = Logger(subsystem: "com.prakashjoshipax.VoiceInk", category: "migration")
        
        // Try to load legacy prompts
        guard let savedPromptsData = UserDefaults.standard.data(forKey: "customPrompts") else {
            logger.notice("No existing prompts found to migrate")
            return []
        }
        
        // First try to decode as new format (in case migration already happened)
        if let newFormatPrompts = try? JSONDecoder().decode([CustomPrompt].self, from: savedPromptsData) {
            logger.notice("Prompts are already in new format, no migration needed")
            return newFormatPrompts
        }
        
        // Try to decode as legacy format
        guard let legacyPrompts = try? JSONDecoder().decode([LegacyCustomPrompt].self, from: savedPromptsData) else {
            logger.error("Failed to decode legacy prompts, starting with empty array")
            return []
        }
        
        logger.notice("Migrating \(legacyPrompts.count) legacy prompts")
        
        // Convert legacy prompts to new format
        let migratedPrompts = legacyPrompts.map { legacyPrompt in
            let triggerWords: [String] = if let triggerWord = legacyPrompt.triggerWord?.trimmingCharacters(in: .whitespacesAndNewlines),
                                           !triggerWord.isEmpty {
                [triggerWord]
            } else {
                []
            }
            
            return CustomPrompt(
                id: legacyPrompt.id,
                title: legacyPrompt.title,
                promptText: legacyPrompt.promptText,
                isActive: legacyPrompt.isActive,
                icon: legacyPrompt.icon,
                description: legacyPrompt.description,
                isPredefined: legacyPrompt.isPredefined,
                triggerWords: triggerWords
            )
        }
        
        // Save migrated prompts in new format
        if let encoded = try? JSONEncoder().encode(migratedPrompts) {
            UserDefaults.standard.set(encoded, forKey: "customPrompts")
            logger.notice("Successfully saved migrated prompts")
        } else {
            logger.error("Failed to save migrated prompts")
        }
        
        return migratedPrompts
    }
} 