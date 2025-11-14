import Foundation
import SwiftUI

class DictionaryContextService {
    static let shared = DictionaryContextService()
    
    private init() {}
    
    private let predefinedWords = "VoiceInk, chatGPT, GPT-4o, GPT-5-mini, Kimi-K2, GLM V4.5, Claude, Claude 4 sonnet, Claude opus, ultrathink, Vibe-coding, groq, cerebras, gpt-oss-120B, deepseek, gemini-2.5, Veo 3, elevenlabs, Kyutai"
    
    func getDictionaryContext() -> String {
        var allWords: [String] = []
        
        allWords.append(predefinedWords)
        
        if let customWords = getCustomDictionaryWords() {
            allWords.append(customWords.joined(separator: ", "))
        }
        
        let wordsText = allWords.joined(separator: ", ")
        return "Important Vocabulary: \(wordsText)"
    }
    private func getCustomDictionaryWords() -> [String]? {
        guard let data = UserDefaults.standard.data(forKey: "CustomDictionaryItems") else {
            return nil
        }
        
        do {
            let items = try JSONDecoder().decode([DictionaryItem].self, from: data)
            let words = items.map { $0.word }
            return words.isEmpty ? nil : words
        } catch {
            return nil
        }
    }
}
