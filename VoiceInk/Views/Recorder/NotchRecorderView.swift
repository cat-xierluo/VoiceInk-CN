import SwiftUI

struct NotchRecorderView: View {
    @ObservedObject var whisperState: WhisperState
    @ObservedObject var recorder: Recorder
    @EnvironmentObject var windowManager: NotchWindowManager
    @State private var isHovering = false
    @State private var showPowerModePopover = false
    @State private var showEnhancementPromptPopover = false
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    
    @EnvironmentObject private var enhancementService: AIEnhancementService
    
    private var menuBarHeight: CGFloat {
        if let screen = NSScreen.main {
            if screen.safeAreaInsets.top > 0 {
                return screen.safeAreaInsets.top
            }
            return NSApplication.shared.mainMenu?.menuBarHeight ?? NSStatusBar.system.thickness
        }
        return NSStatusBar.system.thickness
    }
    
    private var exactNotchWidth: CGFloat {
        if let screen = NSScreen.main {
            if screen.safeAreaInsets.left > 0 {
                return screen.safeAreaInsets.left * 2
            }
            return 200
        }
        return 200
    }
    
    private var leftSection: some View {
        HStack(spacing: 8) {
            let isRecording = whisperState.recordingState == .recording
            let isProcessing = whisperState.recordingState == .transcribing || whisperState.recordingState == .enhancing
            
            RecorderRecordButton(
                isRecording: isRecording,
                isProcessing: isProcessing
            ) {
                Task { await whisperState.toggleRecord() }
            }
            .frame(width: 22)
            
            rightToggleButton
            
            Spacer()
        }
        .frame(width: 64)
        .padding(.leading, 16)
    }
    
    private var rightToggleButton: some View {
        Group {
            if powerModeManager.isPowerModeEnabled {
                RecorderToggleButton(
                    isEnabled: powerModeManager.isPowerModeEnabled,
                    icon: powerModeManager.currentActiveConfiguration.emoji,
                    color: .orange,
                    disabled: false
                ) {
                    showPowerModePopover.toggle()
                }
                .frame(width: 22)
                .popover(isPresented: $showPowerModePopover, arrowEdge: .bottom) {
                    PowerModePopover()
                }
            } else {
                RecorderToggleButton(
                    isEnabled: enhancementService.isEnhancementEnabled,
                    icon: enhancementService.activePrompt?.icon.rawValue ?? "brain",
                    color: .blue,
                    disabled: false
                ) {
                    if enhancementService.isEnhancementEnabled {
                        showEnhancementPromptPopover.toggle()
                    } else {
                        enhancementService.isEnhancementEnabled = true
                    }
                }
                .frame(width: 22)
                .popover(isPresented: $showEnhancementPromptPopover, arrowEdge: .bottom) {
                    EnhancementPromptPopover()
                        .environmentObject(enhancementService)
                }
            }
        }
    }
    
    private var centerSection: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: exactNotchWidth)
            .contentShape(Rectangle())
    }
    
    private var rightSection: some View {
        HStack(spacing: 0) {
            Spacer()
            statusDisplay
        }
        .frame(width: 84)
        .padding(.trailing, 16)
    }
    
    private var statusDisplay: some View {
        RecorderStatusDisplay(
            currentState: whisperState.recordingState,
            audioMeter: recorder.audioMeter,
            menuBarHeight: menuBarHeight
        )
        .frame(width: 70)
        .padding(.trailing, 8)
    }
    
    var body: some View {
        Group {
            if windowManager.isVisible {
                HStack(spacing: 0) {
                    leftSection
                    centerSection
                    rightSection
                }
                .frame(height: menuBarHeight)
                .frame(maxWidth: windowManager.isVisible ? .infinity : 0)
                .background(Color.black)
                .mask {
                    NotchShape(cornerRadius: 10)
                }
                .clipped()
                .onHover { hovering in
                    isHovering = hovering
                }
                .opacity(windowManager.isVisible ? 1 : 0)
            }
        }
    }
}



 
