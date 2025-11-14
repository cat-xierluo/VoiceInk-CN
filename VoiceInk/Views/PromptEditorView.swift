import SwiftUI

struct PromptEditorView: View {
    enum Mode {
        case add
        case edit(CustomPrompt)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(prompt1), .edit(prompt2)):
                return prompt1.id == prompt2.id
            default:
                return false
            }
        }
    }
    
    let mode: Mode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @State private var title: String
    @State private var promptText: String
    @State private var selectedIcon: PromptIcon
    @State private var description: String
    @State private var triggerWords: [String]
    @State private var showingPredefinedPrompts = false
    @State private var useSystemInstructions: Bool
    @State private var showingIconPicker = false
    
    private var isEditingPredefinedPrompt: Bool {
        if case .edit(let prompt) = mode {
            return prompt.isPredefined
        }
        return false
    }
    
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            _title = State(initialValue: "")
            _promptText = State(initialValue: "")
            _selectedIcon = State(initialValue: "doc.text.fill")
            _description = State(initialValue: "")
            _triggerWords = State(initialValue: [])
            _useSystemInstructions = State(initialValue: true)
        case .edit(let prompt):
            _title = State(initialValue: prompt.title)
            _promptText = State(initialValue: prompt.promptText)
            _selectedIcon = State(initialValue: prompt.icon)
            _description = State(initialValue: prompt.description ?? "")
            _triggerWords = State(initialValue: prompt.triggerWords)
            _useSystemInstructions = State(initialValue: prompt.useSystemInstructions)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with modern styling
            HStack {
                Text(isEditingPredefinedPrompt ?
                     L10n.PromptEditor.editTriggerWords.text :
                     (mode == .add ? L10n.PromptEditor.newPrompt.text : L10n.PromptEditor.editPrompt.text))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 12) {
                    Button(L10n.PromptEditor.cancel.text) {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)

                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text(L10n.PromptEditor.save.text)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isEditingPredefinedPrompt ? false : (title.isEmpty || promptText.isEmpty))
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()
            .background(
                Color(NSColor.windowBackgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if isEditingPredefinedPrompt {
                        // Simplified view for predefined prompts - only trigger word editing
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.PromptEditor.editing.format(title))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            Text(L10n.PromptEditor.systemPromptRestriction.text)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            // Trigger Words Field using reusable component
                            TriggerWordsEditor(triggerWords: $triggerWords)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        
                    } else {
                        // Full editing interface for custom prompts
                        // Title and Icon Section with improved layout
                        HStack(spacing: 20) {
                            // Title Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.PromptEditor.title.text)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                TextField(L10n.PromptEditor.titlePlaceholder.text, text: $title)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Icon Selector with preview
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.PromptEditor.icon.text)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                // Preview of selected icon - clickable to open popover (square button)
                                Button(action: {
                                    showingIconPicker = true
                                }) {
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 20))
                                        .foregroundColor(.primary)
                                        .frame(width: 48, height: 48)
                                        .background(Color(NSColor.controlBackgroundColor))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            .popover(isPresented: $showingIconPicker, arrowEdge: .bottom) {
                                IconPickerPopover(selectedIcon: $selectedIcon, isPresented: $showingIconPicker)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.PromptEditor.description.text)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(L10n.PromptEditor.descriptionHelp.text)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            TextField(L10n.PromptEditor.descriptionPlaceholder.text, text: $description)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        .padding(.horizontal)
                        
                        // Prompt Text Section with improved styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.PromptEditor.promptInstructions.text)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(L10n.PromptEditor.promptInstructionsHelp.text)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if !isEditingPredefinedPrompt {
                                HStack(spacing: 8) {
                                    Toggle(L10n.PromptEditor.useSystemInstructions.text, isOn: $useSystemInstructions)

                                    InfoTip(
                                        title: L10n.PromptEditor.systemInstructions.string,
                                        message: L10n.PromptEditor.systemInstructionsHelp.string
                                    )
                                }
                                .padding(.bottom, 4)
                            }

                            TextEditor(text: $promptText)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 200)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(NSColor.textBackgroundColor))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Trigger Words Field using reusable component
                        TriggerWordsEditor(triggerWords: $triggerWords)
                            .padding(.horizontal)
                        
                        if case .add = mode {
                            // Popover keeps templates accessible without taking space in the layout
                            Button(L10n.PromptEditor.predefinedTemplate.text) {
                                showingPredefinedPrompts.toggle()
                            }
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(.windowBackgroundColor).opacity(0.9))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .popover(isPresented: $showingPredefinedPrompts, arrowEdge: .bottom) {
                                PredefinedPromptsView { template in
                                    title = template.title
                                    promptText = template.promptText
                                    selectedIcon = template.icon
                                    description = template.description
                                    showingPredefinedPrompts = false
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
    
    private func save() {
        switch mode {
        case .add:
            enhancementService.addPrompt(
                title: title,
                promptText: promptText,
                icon: selectedIcon,
                description: description.isEmpty ? nil : description,
                triggerWords: triggerWords,
                useSystemInstructions: useSystemInstructions
            )
        case .edit(let prompt):
            let updatedPrompt = CustomPrompt(
                id: prompt.id,
                title: prompt.isPredefined ? prompt.title : title,
                promptText: prompt.isPredefined ? prompt.promptText : promptText,
                isActive: prompt.isActive,
                icon: prompt.isPredefined ? prompt.icon : selectedIcon,
                description: prompt.isPredefined ? prompt.description : (description.isEmpty ? nil : description),
                isPredefined: prompt.isPredefined,
                triggerWords: triggerWords,
                useSystemInstructions: useSystemInstructions
            )
            enhancementService.updatePrompt(updatedPrompt)
        }
    }
}

// Reusable Trigger Words Editor Component
struct TriggerWordsEditor: View {
    @Binding var triggerWords: [String]
    @State private var newTriggerWord: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.PromptEditor.triggerWords.text)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(L10n.PromptEditor.triggerWordsHelp.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Display existing trigger words as tags
            if !triggerWords.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 220))], spacing: 8) {
                    ForEach(triggerWords, id: \.self) { word in
                        TriggerWordItemView(word: word) {
                            triggerWords.removeAll { $0 == word }
                        }
                    }
                }
            }
            
            // Input for new trigger word
            HStack {
                TextField(L10n.PromptEditor.addTriggerPlaceholder.text, text: $newTriggerWord)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .onSubmit {
                        addTriggerWord()
                    }
                
                Button(L10n.Common.add.text) {
                    addTriggerWord()
                }
                .disabled(newTriggerWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func addTriggerWord() {
        let trimmedWord = newTriggerWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return }
        
        // Check for duplicates (case insensitive)
        let lowerCaseWord = trimmedWord.lowercased()
        guard !triggerWords.contains(where: { $0.lowercased() == lowerCaseWord }) else { return }
        
        triggerWords.append(trimmedWord)
        newTriggerWord = ""
    }
}


struct TriggerWordItemView: View {
    let word: String
    let onDelete: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text(word)
                .font(.system(size: 13))
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Spacer(minLength: 8)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isHovered ? .red : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .help(L10n.PromptEditor.removeTriggerHelp.text)
            .onHover { hover in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hover
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.windowBackgroundColor).opacity(0.4))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        }
    }
}

// Icon Picker Popover - shows icons in a grid format without category labels
struct IconPickerPopover: View {
    @Binding var selectedIcon: PromptIcon
    @Binding var isPresented: Bool
    
    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 45, maximum: 52), spacing: 14)
        ]
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(PromptIcon.allCases, id: \.self) { icon in
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            selectedIcon = icon
                            isPresented = false
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedIcon == icon ? Color(NSColor.windowBackgroundColor) : Color(NSColor.controlBackgroundColor))
                                .frame(width: 52, height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedIcon == icon ? Color(NSColor.separatorColor) : Color.secondary.opacity(0.2), lineWidth: selectedIcon == icon ? 2 : 1)
                                )
                            
                            Image(systemName: icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selectedIcon == icon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .frame(width: 400, height: 400)
    }
}
