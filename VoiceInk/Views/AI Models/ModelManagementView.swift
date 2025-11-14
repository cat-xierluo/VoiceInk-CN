import SwiftUI
import SwiftData
import AppKit
import UniformTypeIdentifiers

enum ModelFilter: CaseIterable, Identifiable {
    case recommended
    case local
    case cloud
    case custom

    var id: String {
        switch self {
        case .recommended: return "recommended"
        case .local: return "local"
        case .cloud: return "cloud"
        case .custom: return "custom"
        }
    }

    var label: L10nItem {
        switch self {
        case .recommended: return L10n.AIModels.Filter.recommended
        case .local: return L10n.AIModels.Filter.local
        case .cloud: return L10n.AIModels.Filter.cloud
        case .custom: return L10n.AIModels.Filter.custom
        }
    }
}

struct ModelManagementView: View {
    @ObservedObject var whisperState: WhisperState
    @State private var customModelToEdit: CustomCloudModel?
    @StateObject private var aiService = AIService()
    @StateObject private var customModelManager = CustomModelManager.shared
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @Environment(\.modelContext) private var modelContext
    @StateObject private var whisperPrompt = WhisperPrompt()
    @ObservedObject private var warmupCoordinator = WhisperModelWarmupCoordinator.shared

    @State private var selectedFilter: ModelFilter = .recommended
    @State private var isShowingSettings = false
    
    // State for the unified alert
    @State private var isShowingDeleteAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var deleteActionClosure: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                defaultModelSection
                languageSelectionSection
                availableModelsSection
            }
            .padding(40)
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color(NSColor.controlBackgroundColor))
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text(L10n.AIModels.delete.text), action: deleteActionClosure),
                secondaryButton: .cancel()
            )
        }
    }
    
    private var defaultModelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.AIModels.defaultModel.string)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(whisperState.currentTranscriptionModel?.displayName ?? L10n.AIModels.noModelSelected.string)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CardBackground(isSelected: false))
        .cornerRadius(10)
    }
    
    private var languageSelectionSection: some View {
        LanguageSelectionView(whisperState: whisperState, displayMode: .full, whisperPrompt: whisperPrompt)
    }
    
    private var availableModelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Modern compact pill switcher
                HStack(spacing: 12) {
                    ForEach(ModelFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedFilter = filter
                                isShowingSettings = false
                            }
                        }) {
                            Text(filter.label.text)
                                .font(.system(size: 14, weight: selectedFilter == filter ? .semibold : .medium))
                                .foregroundColor(selectedFilter == filter ? .primary : .primary.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    CardBackground(isSelected: selectedFilter == filter, cornerRadius: 22)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isShowingSettings.toggle()
                    }
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isShowingSettings ? .accentColor : .primary.opacity(0.7))
                        .padding(12)
                        .background(
                            CardBackground(isSelected: isShowingSettings, cornerRadius: 22)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 12)
            
            if isShowingSettings {
                ModelSettingsView(whisperPrompt: whisperPrompt)
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredModels, id: \.id) { model in
                        let isWarming = (model as? LocalModel).map { localModel in
                            warmupCoordinator.isWarming(modelNamed: localModel.name)
                        } ?? false

                        ModelCardRowView(
                            model: model,
                            whisperState: whisperState, 
                            isDownloaded: whisperState.availableModels.contains { $0.name == model.name },
                            isCurrent: whisperState.currentTranscriptionModel?.name == model.name,
                            downloadProgress: whisperState.downloadProgress,
                            modelURL: whisperState.availableModels.first { $0.name == model.name }?.url,
                            isWarming: isWarming,
                            deleteAction: {
                                if let customModel = model as? CustomCloudModel {
                                    alertTitle = L10n.AIModels.Alerts.deleteCustomModelTitle.string
                                    alertMessage = L10n.AIModels.Alerts.deleteCustomModelMessage.format(customModel.displayName)
                                    deleteActionClosure = {
                                        customModelManager.removeCustomModel(withId: customModel.id)
                                        whisperState.refreshAllAvailableModels()
                                    }
                                    isShowingDeleteAlert = true
                                } else if let downloadedModel = whisperState.availableModels.first(where: { $0.name == model.name }) {
                                    alertTitle = L10n.AIModels.Alerts.deleteModelTitle.string
                                    alertMessage = L10n.AIModels.Alerts.deleteModelMessage.format(downloadedModel.name)
                                    deleteActionClosure = {
                                        Task {
                                            await whisperState.deleteModel(downloadedModel)
                                        }
                                    }
                                    isShowingDeleteAlert = true
                                }
                            },
                            setDefaultAction: {
                                Task {
                                    await whisperState.setDefaultTranscriptionModel(model)
                                }
                            },
                            downloadAction: {
                                if let localModel = model as? LocalModel {
                                    Task { await whisperState.downloadModel(localModel) }
                                }
                            },
                            editAction: model.provider == .custom ? { customModel in
                                customModelToEdit = customModel
                            } : nil
                        )
                    }
                    
                    // Import button as a card at the end of the Local list
                    if selectedFilter == .local {
                        HStack(spacing: 8) {
                            Button(action: { presentImportPanel() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text(L10n.AIModels.importLocalModel.text)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(CardBackground(isSelected: false))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)

                            InfoTip(
                                title: L10n.AIModels.CustomModel.importTipTitle.string,
                                message: L10n.AIModels.CustomModel.importTipMessage.string,
                                learnMoreURL: "https://tryvoiceink.com/docs/custom-local-whisper-models"
                            )
                            .help(L10n.AIModels.CustomModel.importTipHelp.string)
                        }
                    }
                    
                    if selectedFilter == .custom {
                        // Add Custom Model Card at the bottom
                        AddCustomModelCardView(
                            customModelManager: customModelManager,
                            editingModel: customModelToEdit
                        ) {
                            // Refresh the models when a new custom model is added
                            whisperState.refreshAllAvailableModels()
                            customModelToEdit = nil // Clear editing state
                        }
                    }
                }
            }
        }
        .padding()
    }

    private var filteredModels: [any TranscriptionModel] {
        switch selectedFilter {
        case .recommended:
            return whisperState.allAvailableModels.filter {
                let recommendedNames = ["ggml-base.en", "ggml-large-v3-turbo-q5_0", "ggml-large-v3-turbo", "whisper-large-v3-turbo"]
                return recommendedNames.contains($0.name)
            }.sorted { model1, model2 in
                let recommendedOrder = ["ggml-base.en", "ggml-large-v3-turbo-q5_0", "ggml-large-v3-turbo", "whisper-large-v3-turbo"]
                let index1 = recommendedOrder.firstIndex(of: model1.name) ?? Int.max
                let index2 = recommendedOrder.firstIndex(of: model2.name) ?? Int.max
                return index1 < index2
            }
        case .local:
            return whisperState.allAvailableModels.filter { $0.provider == .local || $0.provider == .nativeApple || $0.provider == .parakeet }
        case .cloud:
            let cloudProviders: [ModelProvider] = [.groq, .elevenLabs, .deepgram, .mistral, .gemini, .soniox]
            return whisperState.allAvailableModels.filter { cloudProviders.contains($0.provider) }
        case .custom:
            return whisperState.allAvailableModels.filter { $0.provider == .custom }
        }
    }

    // MARK: - Import Panel
    private func presentImportPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "bin")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        panel.title = L10n.AIModels.CustomModel.importPanelTitle.string
        if panel.runModal() == .OK, let url = panel.url {
            Task { @MainActor in
                await whisperState.importLocalModel(from: url)
            }
        }
    }
}
