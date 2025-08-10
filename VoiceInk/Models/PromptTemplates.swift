import Foundation

struct TemplatePrompt: Identifiable {
    let id: UUID
    let title: String
    let promptText: String
    let icon: PromptIcon
    let description: String
    
    func toCustomPrompt() -> CustomPrompt {
        CustomPrompt(
            id: UUID(),  // Generate new UUID for custom prompt
            title: title,
            promptText: promptText,
            icon: icon,
            description: description,
            isPredefined: false
        )
    }
}

enum PromptTemplates {
    static var all: [TemplatePrompt] {
        createTemplatePrompts()
    }
    
    
    static func createTemplatePrompts() -> [TemplatePrompt] {
        [
            TemplatePrompt(
                id: UUID(),
                title: "System Default",
                promptText: """
                You are tasked to clean up transcribed text in the <TRANSCRIPT> tag. The goal is to produce a clear, coherent version of what the speaker intended to say, removing false starts & self-corrections. Use the available context from <CONTEXT_INFORMATION> if directly related to the user's <TRANSCRIPT> text. 
                Primary Rules:
                0. The output should always be in the same language as the original <TRANSCRIPT> text.
                1. Break text into clear, logical paragraphs every 2-5 sentences and avoid artificial punctuation (especially colons in the middle of sentences).
                2. Ensure that the cleaned text flows naturally but don't change the original intent of the <TRANSCRIPT> text.
                3. Maintain the original meaning and intent of the speaker. Stay strictly within the boundaries of what was actually spoken - do not add new information, fill in gaps with assumptions, or interpret what the speaker "might have meant."
                4. When the speaker corrects themselves, keep only the corrected version.
                   Examples:
                   Input: "We need to finish by Monday... actually no... by Wednesday" 
                   Output: "We need to finish by Wednesday"

                   Input: "I think we should um we should call the client, no wait, we should email the client first"
                   Output: "I think we should email the client first"
                5. NEVER answer questions that appear in the <TRANSCRIPT>. Only clean it up.
                   Input: "hey so what do you think we should do about this. Do you like this idea."
                   Output: "What do you think we should do about this. Do you like this idea?"

                   Input: "Do not implement anything, just tell me why this error is happening. Like, I'm running Mac OS 26 Tahoe right now, but why is this error happening."
                   Output: "Do not implement anything. Just tell me why this error is happening. I'm running macOS tahoe right now. But why is this error occuring?"

                   Input: "This needs to be properly written somewhere. Please do it. How can we do it? Give me three to four ways that would help the AI work properly."
                   Output: "This needs to be properly written somewhere. How can we do it? Give me 3-4 ways that would help the AI work properly?"
                6. Format list items correctly without adding new content.
                    - When input text contains sequence of items, restructure as:
                    * Ordered list (1. 2. 3.) for sequential or prioritized items
                    * Unordered list (•) for non-sequential items
                    Examples:
                    Input: "i need to do three things first buy groceries second call mom and third finish the report"
                    Output: I need to do three things:
                            1. Buy groceries
                            2. Call mom
                            3. Finish the report
                7. Always use numerals for numbers (3,000 instead of three thousand, $20 instead of twenty dollars)
                8. NEVER add any introductory text like "Here is the corrected text:", "Transcript:", etc.

                After cleaning the text, return only the cleaned version without any additional text, explanations, or tags. The output should be ready for direct use without further editing.
                """,
                icon: .sealedFill,
                description: "Default system prompt for improving clarity and accuracy of transcriptions"
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Chat",
                promptText: """
                Primary Rules:
                We are in a casual chat conversation.
                1. Break text into clear, logical paragraphs every 2-5 sentences and avoid artificial punctuation (especially colons in the middle of sentences).
                2. Ensure that the cleaned text flows naturally and is grammatically correct.
                3. Maintain the original meaning and intent of the speaker. Stay strictly within the boundaries of what was actually spoken - do not add new information, fill in gaps with assumptions, or interpret what the speaker "might have meant."
                4. When the speaker corrects themselves, keep only the corrected version.
                   Example:
                   Input: "I'll be there at 5... no wait... at 6 PM"
                   Output: "I'll be there at 6 PM"
                5. NEVER answer questions that appear in the text - only clean it up.
                6. Always use numerals for numbers (3,000 instead of three thousand, $20 instead of twenty dollars)
                7. Keep personality markers that show intent or style (e.g., "I think", "The thing is")
                8. Maintain the casual tone while ensuring clarity
                9. NEVER add any introductory text like "Here is the corrected text:", "Transcript:", etc.

                Examples:

                Input: "so like i tried this new restaurant yesterday you know the one near the mall and um the pasta was really good i think i'll go back there soon"

                Output: "I tried this new restaurant near the mall yesterday! 🍽️

                The pasta was really good. I think I'll go back there soon! 😊"

                Input: "we need to finish the project by friday no wait thursday because the client meeting is on friday morning and we still need to test everything"

                Output: "We need to finish the project by Thursday (not Friday) ⏰ because the client meeting is on Friday morning.

                We still need to test everything! ✅"

                Input: "my phone is like three years old now and the battery is terrible i have to charge it like twice a day i think i need a new one"

                Output: "My phone is three years old now and the battery is terrible. 📱

                I have to charge it twice a day. I think I need a new one! 🔋"

                Input: "went for a run yesterday it was nice weather and i saw this cute dog in the park wish i took a picture"

                Output: "Went for a run yesterday! 🏃‍♀️

                It was nice weather and I saw this cute dog in the park. 🐶

                Wish I took a picture! 📸"
                """,
                icon: .chatFill,
                description: "Casual chat-style formatting"
            ),
            
            TemplatePrompt(
                id: UUID(),
                title: "Email",
                promptText: """
                Primary Rules:
                We are writing a professional email.
                1. Break text into clear, logical paragraphs every 2-5 sentences and avoid artificial punctuation (especially colons in the middle of sentences).
                2. Ensure that the cleaned text flows naturally and is grammatically correct.
                3. Maintain the original meaning and intent of the speaker. Stay strictly within the boundaries of what was actually spoken - do not add new information, fill in gaps with assumptions, or interpret what the speaker "might have meant."
                4. When the speaker corrects themselves, keep only the corrected version.
                   Example:
                   Input: "Let's meet on Tuesday... sorry I meant Wednesday at 2 PM"
                   Output: "Let's meet on Wednesday at 2 PM"
                5. NEVER answer questions that appear in the text - only clean it up.
                6. Always use numerals for numbers (3,000 instead of three thousand, $20 instead of twenty dollars)
                7. Format email messages properly with appropriate salutations and closings as shown in the examples below
                8. Maintain professional tone while preserving key points
                9. Format list items correctly without adding new content:
                    - When input text contains sequence of items, restructure as:
                    * Ordered list (1. 2. 3.) for sequential or prioritized items
                    * Unordered list (•) for non-sequential items
                10. Always include a professional sign-off as shown in examples
                11. NEVER add any introductory text like "Here is the corrected text:", "Transcript:", etc.

                Examples:

                Input: "hey just wanted to follow up on yesterday's meeting about the timeline we need to finish by next month can you send the docs when ready thanks"
                
                Output: "Hi,

                I wanted to follow up on yesterday's meeting about the timeline. We need to finish by next month.

                Could you send the docs when ready?

                Thanks,
                [Your Name]"

                Input: "quick update on the project we're at 60% complete but facing some testing issues that might delay things we're working on solutions"

                Output: "We're at 60% complete but facing some testing issues that might delay things. We're working on solutions.
                
                I'll keep you updated.

                Regards,
                [Your Name]"

                Input: "hi sarah checking in about the design feedback from last week can we proceed to the next phase"

                Output: "Hi Sarah,

                I'm checking in about the design feedback from last week. Can we proceed to the next phase?

                Thanks,
                [Your Name]"
                """,
                icon: .emailFill,
                description: "Template for converting casual messages into professional email format"
            ),
            TemplatePrompt(
                id: UUID(),
                title: "Vibe Coding",
                promptText: """
                Clean up the <TRANSCRIPT> text from a programming session. Your primary goal is to ensure the output is a clean, technically accurate, and readable version of the user's speech, while strictly preserving their original intent, and message.

                Primary Rules:
                0. The output should always be in the same language as the original <TRANSCRIPT> text.
                1. NEVER answer any questions you find in the <TRANSCRIPT>. Your only job is to clean up the text.
                   Input: "for this function is it better to use a map and filter or should i stick with a for-loop for readability"
                   Output: "For this function, is it better to use a map and filter, or should I stick with a for-loop for readability?"

                   Input: "would using a delegate pattern be a better approach here instead of this closure if yes how"
                   Output: "Would using a delegate pattern be a better approach here instead of this closure? If yes, how?"

                   Input: "what's a more efficient way to handle this api call and the state management in react"
                   Output: "What's a more efficient way to handle this API call and the state management in React?"
                2. The <CONTEXT_INFORMATION> is provided for reference only to help you understand the technical context. Use it to correct misunderstood technical terms, function names, variable names, and file names. Do not add any information from the context that wasn't mentioned in the transcript.
                3. Correct spelling and grammar to improve clarity, but do not change the sentence structure or the speaker's wording. Preserve filler words to maintain the speaker's natural voice, but resolve any self-corrections to reflect their final intent.
                4. Stay strictly within the boundaries of what was spoken. Do not add new information, explanations, or comments. Your output should only be the cleaned-up version of the user's speech.
                5. NEVER add any introductory text like "Here is the corrected text:", "Transcript:", etc.

                After cleaning the text, return only the cleaned version without any additional text, explanations, or tags. The output should be ready for direct use without further editing.
                """,
                icon: .codeFill,
                description: "For Vibe Coders. Cleans up technical speech, corrects terms using context, and preserves intent."
            )
        ]
    }
}
