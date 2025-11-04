import SwiftUI

/// A reusable grid component for selecting prompts with a plus button to add new ones
struct PromptSelectionGrid: View {
    @EnvironmentObject private var enhancementService: AIEnhancementService
    
    let prompts: [CustomPrompt]
    let selectedPromptId: UUID?
    let onPromptSelected: (CustomPrompt) -> Void
    let onEditPrompt: ((CustomPrompt) -> Void)?
    let onDeletePrompt: ((CustomPrompt) -> Void)?
    let onAddNewPrompt: (() -> Void)?
    
    init(
        prompts: [CustomPrompt],
        selectedPromptId: UUID?,
        onPromptSelected: @escaping (CustomPrompt) -> Void,
        onEditPrompt: ((CustomPrompt) -> Void)? = nil,
        onDeletePrompt: ((CustomPrompt) -> Void)? = nil,
        onAddNewPrompt: (() -> Void)? = nil
    ) {
        self.prompts = prompts
        self.selectedPromptId = selectedPromptId
        self.onPromptSelected = onPromptSelected
        self.onEditPrompt = onEditPrompt
        self.onDeletePrompt = onDeletePrompt
        self.onAddNewPrompt = onAddNewPrompt
    }
    
<<<<<<< HEAD
    private var sortedPrompts: [CustomPrompt] {
        prompts.sorted { prompt1, prompt2 in
            // Predefined prompts come first
            if prompt1.isPredefined && !prompt2.isPredefined {
                return true
            }
            if !prompt1.isPredefined && prompt2.isPredefined {
                return false
            }
            
            // Among predefined prompts: Default first, then Assistant
            if prompt1.isPredefined && prompt2.isPredefined {
                if prompt1.id == PredefinedPrompts.defaultPromptId {
                    return true
                }
                if prompt2.id == PredefinedPrompts.defaultPromptId {
                    return false
                }
                if prompt1.id == PredefinedPrompts.assistantPromptId {
                    return true
                }
                if prompt2.id == PredefinedPrompts.assistantPromptId {
                    return false
                }
            }
            
            // Custom prompts: sort alphabetically by title
            return prompt1.title.localizedCaseInsensitiveCompare(prompt2.title) == .orderedAscending
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if sortedPrompts.isEmpty {
                Text(NSLocalizedString("No prompts available", comment: "No prompts available"))
=======

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if prompts.isEmpty {
                Text("No prompts available")
>>>>>>> upstream/main
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                let columns = [
                    GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 36)
                ]
                
                LazyVGrid(columns: columns, spacing: 16) {
<<<<<<< HEAD
                    ForEach(sortedPrompts) { prompt in
=======
                    ForEach(prompts) { prompt in
>>>>>>> upstream/main
                        prompt.promptIcon(
                            isSelected: selectedPromptId == prompt.id,
                            onTap: { 
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    onPromptSelected(prompt)
                                }
                            },
                            onEdit: onEditPrompt,
                            onDelete: onDeletePrompt
                        )
                    }
                    
                    if let onAddNewPrompt = onAddNewPrompt {
                        CustomPrompt.addNewButton {
                            onAddNewPrompt()
                        }
<<<<<<< HEAD
                        .help(NSLocalizedString("Add new prompt", comment: "Add new prompt"))
=======
                        .help("Add new prompt")
>>>>>>> upstream/main
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                // Helpful tip for users
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
<<<<<<< HEAD
Text(NSLocalizedString("Right-click on prompts to edit or delete", comment: "Right-click on prompts to edit or delete"))
=======
                    Text("Double-click to edit • Right-click for more options")
>>>>>>> upstream/main
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
            }
        }
    }
}
<<<<<<< HEAD

=======
>>>>>>> upstream/main
