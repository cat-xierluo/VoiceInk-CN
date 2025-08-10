import SwiftUI
import AppKit

/// Custom NSPanel that can become key window for text editing
class EditablePanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}

/// Manages the presentation and dismissal of the `TranscriptionFallbackView`.
class TranscriptionFallbackManager {
    static let shared = TranscriptionFallbackManager()
    
    private var fallbackWindow: NSPanel?
    
    /// Observer that listens for the fallback window losing key status so it can be dismissed automatically.
    private var windowObserver: Any?
    
    private init() {}
    
    /// Displays the fallback window with the provided transcription text.
    @MainActor
    func showFallback(for text: String) {
        dismiss()
        
        let fallbackView = TranscriptionFallbackView(
            transcriptionText: text,
            onCopy: { [weak self] in
                self?.dismiss()
            },
            onClose: { [weak self] in
                self?.dismiss()
            },
            onTextChange: { [weak self] newText in
                self?.resizeWindow(for: newText)
            }
        )
        
        let hostingController = NSHostingController(rootView: fallbackView)
        
        let finalSize = calculateOptimalSize(for: text)
        
        let panel = createFallbackPanel(with: finalSize)
        panel.contentView = hostingController.view
        
        self.fallbackWindow = panel
        
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            panel.animator().alphaValue = 1
        } completionHandler: {
            DispatchQueue.main.async {
                panel.makeFirstResponder(hostingController.view)
            }
        }
        
        // Automatically close the window when the user clicks outside of it.
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    /// Dynamically resizes the window based on new text content
    @MainActor
    private func resizeWindow(for text: String) {
        guard let window = fallbackWindow else { return }
        
        let newSize = calculateOptimalSize(for: text)
        let currentFrame = window.frame
        
        // Preserve the bottom anchor and center horizontally while resizing
        let newX = currentFrame.midX - (newSize.width / 2)
        let newY = currentFrame.minY // keep the bottom position constant
        
        let newFrame = NSRect(x: newX, y: newY, width: newSize.width, height: newSize.height)
        
        // Animate the resize
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            window.animator().setFrame(newFrame, display: true)
        }
    }
    
    /// Dismisses the fallback window with an animation.
    @MainActor
    func dismiss() {
        guard let window = fallbackWindow else { return }
        
        fallbackWindow = nil
        
        // Remove the key-window observer if it exists.
        if let observer = windowObserver {
            NotificationCenter.default.removeObserver(observer)
            windowObserver = nil
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            window.animator().alphaValue = 0
        }, completionHandler: {
            window.close()
        })
    }
    
    private func calculateOptimalSize(for text: String) -> CGSize {
        let minWidth: CGFloat = 280
        let maxWidth: CGFloat = 400
        let minHeight: CGFloat = 80
        let maxHeight: CGFloat = 300
        let horizontalPadding: CGFloat = 48
        let verticalPadding: CGFloat = 56
        
        let font = NSFont.systemFont(ofSize: 14, weight: .regular)
        let textStorage = NSTextStorage(string: text, attributes: [.font: font])
        let textContainer = NSTextContainer(size: CGSize(width: maxWidth - horizontalPadding, height: .greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.glyphRange(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        
        let idealWidth = usedRect.width + horizontalPadding
        let idealHeight = usedRect.height + verticalPadding
        
        let finalWidth = min(maxWidth, max(minWidth, idealWidth))
        let finalHeight = min(maxHeight, max(minHeight, idealHeight))
        
        return CGSize(width: finalWidth, height: finalHeight)
    }
    
    private func createFallbackPanel(with finalSize: NSSize) -> NSPanel {
        let panel = EditablePanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovable = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.acceptsMouseMovedEvents = true
        panel.worksWhenModal = true
        
        if let activeScreen = NSScreen.main {
            let screenRect = activeScreen.visibleFrame
            let xPos = screenRect.midX - (finalSize.width / 2)
            let padding: CGFloat = 40 // increased distance from bottom of visible frame (above Dock)
            let yPos = screenRect.minY + padding
            panel.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        panel.setContentSize(finalSize)
        
        return panel
    }
} 