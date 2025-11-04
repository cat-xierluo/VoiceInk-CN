import SwiftUI
import AppKit

struct ModelCardRowView: View {
    let model: any TranscriptionModel
<<<<<<< HEAD
=======
    @ObservedObject var whisperState: WhisperState
>>>>>>> upstream/main
    let isDownloaded: Bool
    let isCurrent: Bool
    let downloadProgress: [String: Double]
    let modelURL: URL?
<<<<<<< HEAD
=======
    let isWarming: Bool
>>>>>>> upstream/main
    
    // Actions
    var deleteAction: () -> Void
    var setDefaultAction: () -> Void
    var downloadAction: () -> Void
    var editAction: ((CustomCloudModel) -> Void)?
<<<<<<< HEAD
    
=======
>>>>>>> upstream/main
    var body: some View {
        Group {
            switch model.provider {
            case .local:
                if let localModel = model as? LocalModel {
                    LocalModelCardView(
                        model: localModel,
                        isDownloaded: isDownloaded,
                        isCurrent: isCurrent,
                        downloadProgress: downloadProgress,
                        modelURL: modelURL,
<<<<<<< HEAD
=======
                        isWarming: isWarming,
>>>>>>> upstream/main
                        deleteAction: deleteAction,
                        setDefaultAction: setDefaultAction,
                        downloadAction: downloadAction
                    )
<<<<<<< HEAD
=======
                } else if let importedModel = model as? ImportedLocalModel {
                    ImportedLocalModelCardView(
                        model: importedModel,
                        isDownloaded: isDownloaded,
                        isCurrent: isCurrent,
                        modelURL: modelURL,
                        deleteAction: deleteAction,
                        setDefaultAction: setDefaultAction
                    )
                }
                    case .parakeet:
            if let parakeetModel = model as? ParakeetModel {
                ParakeetModelCardRowView(
                    model: parakeetModel,
                        whisperState: whisperState
                    )
>>>>>>> upstream/main
                }
            case .nativeApple:
                if let nativeAppleModel = model as? NativeAppleModel {
                    NativeAppleModelCardView(
                        model: nativeAppleModel,
                        isCurrent: isCurrent,
                        setDefaultAction: setDefaultAction
                    )
                }
<<<<<<< HEAD
            case .groq, .elevenLabs, .deepgram, .mistral:
=======
            case .groq, .elevenLabs, .deepgram, .mistral, .gemini, .soniox:
>>>>>>> upstream/main
                if let cloudModel = model as? CloudModel {
                    CloudModelCardView(
                        model: cloudModel,
                        isCurrent: isCurrent,
                        setDefaultAction: setDefaultAction
                    )
                }
            case .custom:
                if let customModel = model as? CustomCloudModel {
                    CustomModelCardView(
                        model: customModel,
                        isCurrent: isCurrent,
                        setDefaultAction: setDefaultAction,
                        deleteAction: deleteAction,
                        editAction: editAction ?? { _ in }
                    )
                }
            }
        }
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> upstream/main
