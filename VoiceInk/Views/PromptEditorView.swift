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
<<<<<<< HEAD
=======
    @State private var useSystemInstructions: Bool
    @State private var showingIconPicker = false
>>>>>>> upstream/main
    
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
<<<<<<< HEAD
            _selectedIcon = State(initialValue: .documentFill)
            _description = State(initialValue: "")
            _triggerWords = State(initialValue: [])
=======
            _selectedIcon = State(initialValue: "doc.text.fill")
            _description = State(initialValue: "")
            _triggerWords = State(initialValue: [])
            _useSystemInstructions = State(initialValue: true)
>>>>>>> upstream/main
        case .edit(let prompt):
            _title = State(initialValue: prompt.title)
            _promptText = State(initialValue: prompt.promptText)
            _selectedIcon = State(initialValue: prompt.icon)
            _description = State(initialValue: prompt.description ?? "")
            _triggerWords = State(initialValue: prompt.triggerWords)
<<<<<<< HEAD
=======
            _useSystemInstructions = State(initialValue: prompt.useSystemInstructions)
>>>>>>> upstream/main
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with modern styling
            HStack {
<<<<<<< HEAD
Text(isEditingPredefinedPrompt ? NSLocalizedString("Edit Trigger Words", comment: "Edit Trigger Words") : (mode == .add ? NSLocalizedString("New Prompt", comment: "New Prompt") : NSLocalizedString("Edit Prompt", comment: "Edit Prompt")))
=======
                Text(isEditingPredefinedPrompt ? "Edit Trigger Words" : (mode == .add ? "New Prompt" : "Edit Prompt"))
>>>>>>> upstream/main
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 12) {
<<<<<<< HEAD
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
=======
                    Button("Cancel") {
>>>>>>> upstream/main
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    
                    Button {
                        save()
                        dismiss()
                    } label: {
<<<<<<< HEAD
                        Text(NSLocalizedString("Save", comment: "Save button"))
=======
                        Text("Save")
>>>>>>> upstream/main
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
<<<<<<< HEAD
                            Text(NSLocalizedString("Editing: \(title)", comment: "Editing: \(title)"))
=======
                            Text("Editing: \(title)")
>>>>>>> upstream/main
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
<<<<<<< HEAD
Text(NSLocalizedString("You can only customize the trigger words for system prompts.", comment: "You can only customize the trigger words for system prompts."))
=======
                            Text("You can only customize the trigger words for system prompts.")
>>>>>>> upstream/main
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
<<<<<<< HEAD
Text(NSLocalizedString("Title", comment: "Title"))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
TextField(NSLocalizedString("Enter a short, descriptive title", comment: "Enter a short, descriptive title"), text: $title)
=======
                                Text("Title")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                TextField("Enter a short, descriptive title", text: $title)
>>>>>>> upstream/main
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Icon Selector with preview
                            VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("Icon", comment: "Icon"))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Menu {
                                    IconMenuContent(selectedIcon: $selectedIcon)
                                } label: {
                                    HStack {
                                        Image(systemName: selectedIcon.rawValue)
                                            .font(.system(size: 16))
                                            .foregroundColor(.accentColor)
                                            .frame(width: 24)
                                        
                                        Text(selectedIcon.title)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(8)
                                }
                                .frame(width: 180)
=======
                                Text("Icon")
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
>>>>>>> upstream/main
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("Description", comment: "Description"))
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
Text(NSLocalizedString("Add a brief description of what this prompt does", comment: "Add a brief description of what this prompt does"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
TextField(NSLocalizedString("Enter a description", comment: "Enter a description"), text: $description)
=======
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Add a brief description of what this prompt does")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter a description", text: $description)
>>>>>>> upstream/main
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        .padding(.horizontal)
                        
                        // Prompt Text Section with improved styling
                        VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("Prompt Instructions", comment: "Prompt Instructions"))
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
Text(NSLocalizedString("Define how AI should enhance your transcriptions", comment: "Define how AI should enhance your transcriptions"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
=======
                            Text("Prompt Instructions")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Define how AI should enhance your transcriptions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if !isEditingPredefinedPrompt {
                                HStack(spacing: 8) {
                                    Toggle("Use System Instructions", isOn: $useSystemInstructions)
                                    
                                    InfoTip(
                                        title: "System Instructions",
                                        message: "If enabled, your instructions are combined with a general-purpose template to improve transcription quality.\n\nDisable for full control over the AI's system prompt (for advanced users)."
                                    )
                                }
                                .padding(.bottom, 4)
                            }

>>>>>>> upstream/main
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
<<<<<<< HEAD
                            // Templates Section with modern styling
                            VStack(alignment: .leading, spacing: 16) {
Text(NSLocalizedString("Start with a Predefined Template", comment: "Start with a Predefined Template"))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                let columns = [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ]
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(PromptTemplates.all) { template in
                                        CleanTemplateButton(prompt: template) {
                                            title = template.title
                                            promptText = template.promptText
                                            selectedIcon = template.icon
                                            description = template.description
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.windowBackgroundColor).opacity(0.6))
                            )
                            .padding(.horizontal)
=======
                            // Popover keeps templates accessible without taking space in the layout
                            Button("Start with a Predefined Template") {
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
>>>>>>> upstream/main
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
<<<<<<< HEAD
                triggerWords: triggerWords
=======
                triggerWords: triggerWords,
                useSystemInstructions: useSystemInstructions
>>>>>>> upstream/main
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
<<<<<<< HEAD
                triggerWords: triggerWords
=======
                triggerWords: triggerWords,
                useSystemInstructions: useSystemInstructions
>>>>>>> upstream/main
            )
            enhancementService.updatePrompt(updatedPrompt)
        }
    }
}

<<<<<<< HEAD
// Clean template button with minimal styling
struct CleanTemplateButton: View {
    let prompt: TemplatePrompt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Clean icon design
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: prompt.icon.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(prompt.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// Keep the old TemplateButton for backward compatibility if needed elsewhere
struct TemplateButton: View {
    let prompt: TemplatePrompt
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: prompt.icon.rawValue)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 28, height: 28)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(height: 60)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

=======
>>>>>>> upstream/main
// Reusable Trigger Words Editor Component
struct TriggerWordsEditor: View {
    @Binding var triggerWords: [String]
    @State private var newTriggerWord: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
Text(NSLocalizedString("Trigger Words", comment: "Trigger Words"))
                .font(.headline)
                .foregroundColor(.secondary)
            
Text(NSLocalizedString("Add multiple words that can activate this prompt", comment: "Add multiple words that can activate this prompt"))
=======
            Text("Trigger Words")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add multiple words that can activate this prompt")
>>>>>>> upstream/main
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
<<<<<<< HEAD
TextField(NSLocalizedString("Add trigger word", comment: "Add trigger word"), text: $newTriggerWord)
=======
                TextField("Add trigger word", text: $newTriggerWord)
>>>>>>> upstream/main
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .onSubmit {
                        addTriggerWord()
                    }
                
<<<<<<< HEAD
                Button(NSLocalizedString("Add", comment: "Add button")) {
=======
                Button("Add") {
>>>>>>> upstream/main
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

<<<<<<< HEAD
// Icon menu content for better organization
struct IconMenuContent: View {
    @Binding var selectedIcon: PromptIcon
    
    var body: some View {
        Group {
IconMenuSection(title: NSLocalizedString("Document & Text", comment: "Document & Text"), icons: [.documentFill, .textbox, .sealedFill], selectedIcon: $selectedIcon)
IconMenuSection(title: NSLocalizedString("Communication", comment: "Communication"), icons: [.chatFill, .messageFill, .emailFill], selectedIcon: $selectedIcon)
IconMenuSection(title: NSLocalizedString("Professional", comment: "Professional"), icons: [.meetingFill, .presentationFill, .briefcaseFill], selectedIcon: $selectedIcon)
IconMenuSection(title: NSLocalizedString("Technical", comment: "Technical"), icons: [.codeFill, .terminalFill, .gearFill], selectedIcon: $selectedIcon)
IconMenuSection(title: NSLocalizedString("Content", comment: "Content"), icons: [.blogFill, .notesFill, .bookFill, .bookmarkFill, .pencilFill], selectedIcon: $selectedIcon)
IconMenuSection(title: NSLocalizedString("Media & Creative", comment: "Media & Creative"), icons: [.videoFill, .micFill, .musicFill, .photoFill, .brushFill], selectedIcon: $selectedIcon)
        }
    }
}

// Icon menu section for better organization
struct IconMenuSection: View {
    let title: String
    let icons: [PromptIcon]
    @Binding var selectedIcon: PromptIcon
    
    var body: some View {
        Group {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            ForEach(icons, id: \.self) { icon in
                Button(action: { selectedIcon = icon }) {
                    Label(icon.title, systemImage: icon.rawValue)
                }
            }
            if title != "Media & Creative" {
                Divider()
            }
        }
    }
}
=======
>>>>>>> upstream/main

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
<<<<<<< HEAD
.help(NSLocalizedString("Remove word", comment: "Remove word"))
=======
            .help("Remove word")
>>>>>>> upstream/main
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
<<<<<<< HEAD
} 
=======
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
>>>>>>> upstream/main
