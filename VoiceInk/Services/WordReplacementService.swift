import Foundation

class WordReplacementService {
    static let shared = WordReplacementService()
    
    private init() {}
    
    func applyReplacements(to text: String) -> String {
        guard let replacements = UserDefaults.standard.dictionary(forKey: "wordReplacements") as? [String: String],
              !replacements.isEmpty else {
            return text // No replacements to apply
        }
        
        var modifiedText = text
        
        // Apply each replacement (case-insensitive, whole word)
        for (original, replacement) in replacements {
            let isPhrase = original.contains(" ") || original.trimmingCharacters(in: .whitespacesAndNewlines) != original

            if isPhrase {
                 modifiedText = modifiedText.replacingOccurrences(of: original, with: replacement, options: .caseInsensitive)
            } else {
                // Create a regular expression that matches the word boundaries
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: original))\\b"
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(modifiedText.startIndex..., in: modifiedText)
                    modifiedText = regex.stringByReplacingMatches(
                        in: modifiedText,
                        options: [],
                        range: range,
                        withTemplate: replacement
                    )
                }
            }
        }
        
        return modifiedText
    }
}
