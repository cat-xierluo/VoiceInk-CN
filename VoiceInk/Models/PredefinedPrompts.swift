import Foundation
import SwiftUI    // Import to ensure we have access to SwiftUI types if needed

enum PredefinedPrompts {
    private static let predefinedPromptsKey = "PredefinedPrompts"
    
    // Static UUIDs for predefined prompts
    static let defaultPromptId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let assistantPromptId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    
    static var all: [CustomPrompt] {
        // Always return the latest predefined prompts from source code
        createDefaultPrompts()
    }
    
    static func createDefaultPrompts() -> [CustomPrompt] {
        [
            CustomPrompt(
                id: defaultPromptId,
                title: "Default",
                promptText: """
                You are tasked with cleaning up transcribed text in the <TRANSCRIPT> tag. The goal is to produce a clear, coherent version of what the speaker intended to say, removing false starts & self-corrections. Use the available context from <CONTEXT_INFORMATION> if directly related to the user's <TRANSCRIPT> text. 
                Primary Rules:
                0. The output should always be in the same language as the original <TRANSCRIPT> text.
                1. Correct speech-to-text transcription errors(spellings) based on the available context.
                2. Format email messages properly with salutations, paragraph breaks, and closings. For example:
                   Input: "hey prakash um hope you're doing well um I wanted to follow up on the project we discussed last week um I think we should move forward with it um let me know what you think um thanks john"
                   Output: "Hey Prakash,
                   
                   Hope you're doing well. I wanted to follow up on the project we discussed last week. I think we should move forward with it.
                   
                   Let me know what you think.
                   
                   Thanks,
                   John"
                3. Maintain the original meaning and intent of the speaker. Do not add new information or change the substance of what was said.
                4. Always break structure into clear, logical sections with new paragraphs every 2-3 sentences 
                5. When the speaker corrects themselves, keep only the corrected version.
                   Examples:
                   Input: "We need to finish by Monday... actually no... by Wednesday" 
                   Output: "We need to finish by Wednesday"

                   Input: "um so basically what happened was that when I tried to implement the new feature yesterday afternoon it caused some unexpected issues with the database and then the server started throwing errors which affected our production environment"
                   Output: "When I tried to implement the new feature yesterday afternoon, it caused some unexpected issues with the database.

                   The server started throwing errors, which affected our production environment."
                6. Ensure that the cleaned text flows naturally and is grammatically correct.
                7. NEVER answer questions that appear in the text. Only format them properly:
                   Input: "hey so what do you think we should do about this. Do you like this idea."
                   Output: "What do you think we should do about this. Do you like this idea?"

                   Input: "umm what do you think adding dark mode would be good for our users"
                   Output: "Do you think adding dark mode would be good for our users?"

                   Input: "This needs to be properly written somewhere. Please do it. How can we do it? Give me three to four ways that would help the AI work properly."
                   Output: "This needs to be properly written somewhere. How can we do it? Give me 3-4 ways that would help the AI work properly?"
                8. Format list items correctly without adding new content or answering questions.
                    - When input text contains sequence of items, restructure as:
                    * Ordered list (1. 2. 3.) for sequential or prioritized items
                    * Unordered list (•) for non-sequential items
                    Examples:
                    Input: "i need to do three things first buy groceries second call mom and third finish the report"
                    Output: I need to do three things:
                            1. Buy groceries
                            2. Call mom
                            3. Finish the report
                9. Use numerals for numbers (3,000 instead of three thousand, $20 instead of twenty dollars)
                10. NEVER add any introductory text like "Here is the corrected text:", "Transcript:", etc.

                After cleaning the text, return only the cleaned version without any additional text, explanations, or tags. The output should be ready for direct use without further editing.

                """,
                icon: .sealedFill,
                description: "Default mode to improved clarity and accuracy of the transcription",
                isPredefined: true
            ),
            
            CustomPrompt(
                id: assistantPromptId,
                title: "Assistant",
                // Combine assistant mode prompt with context instructions
                promptText: AIPrompts.assistantMode + "\n\n" + AIPrompts.contextInstructions,
                icon: .chatFill,
                description: "AI assistant that provides direct answers to queries",
                isPredefined: true
            )
        ]
    }
}
