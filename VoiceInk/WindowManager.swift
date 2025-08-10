import SwiftUI
import AppKit

class WindowManager {
    static let shared = WindowManager()
    
    private init() {}
    
    func configureWindow(_ window: NSWindow) {
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .windowBackgroundColor
        window.isReleasedWhenClosed = false
        window.title = "VoiceInk"
        window.collectionBehavior = [.fullScreenPrimary]
        window.level = .normal
        window.isOpaque = true
        window.isMovableByWindowBackground = false
        window.minSize = NSSize(width: 0, height: 0)
        window.orderFrontRegardless()
    }
    
    func configureOnboardingPanel(_ window: NSWindow) {
        window.styleMask = [.titled, .fullSizeContentView, .resizable]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .normal
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.title = "VoiceInk Onboarding"
        window.isOpaque = false
        window.minSize = NSSize(width: 900, height: 780)
        window.makeKeyAndOrderFront(nil)
    }
    
    func createMainWindow(contentView: NSView) -> NSWindow {
        let defaultSize = NSSize(width: 940, height: 780)
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        let xPosition = (screenFrame.width - defaultSize.width) / 2 + screenFrame.minX
        let yPosition = (screenFrame.height - defaultSize.height) / 2 + screenFrame.minY
        
        let window = NSWindow(
            contentRect: NSRect(x: xPosition, y: yPosition, width: defaultSize.width, height: defaultSize.height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        configureWindow(window)
        window.contentView = contentView
        
        let delegate = WindowStateDelegate()
        window.delegate = delegate
        
        return window
    }
}

class WindowStateDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        window.orderOut(nil)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        guard let _ = notification.object as? NSWindow else { return }
        NSApp.activate(ignoringOtherApps: true)
    }
} 
