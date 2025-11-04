import Foundation
import AppKit
import SelectedTextKit

class SelectedTextService {
    static func fetchSelectedText() async -> String? {
        let strategies: [TextStrategy] = [.accessibility, .menuAction, .shortcut]
        do {
            let selectedText = try await SelectedTextManager.shared.getSelectedText(strategies: strategies)
            return selectedText
        } catch {
            print("Failed to get selected text: \(error)")
            return nil
        }
    }
}
