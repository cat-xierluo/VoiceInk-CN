import Foundation
import AppKit

class SelectedTextService {
    
    // Private pasteboard type to avoid clipboard history pollution
    private static let privatePasteboardType = NSPasteboard.PasteboardType("com.prakashjoshipax.VoiceInk.transient")

    static func fetchSelectedText() -> String? {
        // Don't check for selected text within VoiceInk itself
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              frontmostApp.bundleIdentifier != "com.prakashjoshipax.VoiceInk" else {
            return nil
        }

        let pasteboard = NSPasteboard.general
        
        // Save original clipboard content
        let originalPasteboardItems = pasteboard.pasteboardItems?.map { item in
            (item.types, item.data(forType: item.types.first ?? .string))
        }

        // Clear clipboard to prepare for selection detection
        pasteboard.clearContents()
        
        // Simulate Cmd+C to copy any selected text
        let source = CGEventSource(stateID: .hidSystemState)
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        cmdDown?.flags = .maskCommand
        let cDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        cDown?.flags = .maskCommand
        let cUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        cUp?.flags = .maskCommand
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        cmdDown?.post(tap: .cghidEventTap)
        cDown?.post(tap: .cghidEventTap)
        cUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
        
        // Wait for copy operation to complete
        Thread.sleep(forTimeInterval: 0.1)

        // Read the copied text
        let selectedText = pasteboard.string(forType: .string)
        
        // Restore original clipboard content
        pasteboard.clearContents()
        if let originalItems = originalPasteboardItems {
            for (types, data) in originalItems {
                if let data = data {
                    let pasteboardItem = NSPasteboardItem()
                    pasteboardItem.setData(data, forType: types.first ?? .string)
                    pasteboard.writeObjects([pasteboardItem])
                }
            }
        }
        
        // Clear clipboard history by writing transient data
        let transientItem = NSPasteboardItem()
        transientItem.setString("", forType: privatePasteboardType)
        pasteboard.writeObjects([transientItem])

        return selectedText
    }
}