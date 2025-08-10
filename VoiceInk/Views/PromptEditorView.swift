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
            _selectedIcon = State(initialValue: .documentFill)
            _description = State(initialValue: "")
            _triggerWords = State(initialValue: [])
        case .edit(let prompt):
            _title = State(initialValue: prompt.title)
            _promptText = State(initialValue: prompt.promptText)
            _selectedIcon = State(initialValue: prompt.icon)
            _description = State(initialValue: prompt.description ?? "")
            _triggerWords = State(initialValue: prompt.triggerWords)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with modern styling
            HStack {
                Text(isEditingPredefinedPrompt ? "Edit Trigger Words" : (mode == .add ? "New Prompt" : "Edit Prompt"))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    
                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text("Save")
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
                            Text("Editing: \(title)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            Text("You can only customize the trigger words for system prompts.")
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
                                Text("Title")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                TextField("Enter a short, descriptive title", text: $title)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Icon Selector with preview
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Icon")
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
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Add a brief description of what this prompt does")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter a description", text: $description)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        .padding(.horizontal)
                        
                        // Prompt Text Section with improved styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prompt Instructions")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Define how AI should enhance your transcriptions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
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
                            // Templates Section with modern styling
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Start with a Predefined Template")
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
                triggerWords: triggerWords
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
                triggerWords: triggerWords
            )
            enhancementService.updatePrompt(updatedPrompt)
        }
    }
}

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

// Reusable Trigger Words Editor Component
struct TriggerWordsEditor: View {
    @Binding var triggerWords: [String]
    @State private var newTriggerWord: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trigger Words")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add multiple words that can activate this prompt")
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
                TextField("Add trigger word", text: $newTriggerWord)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .onSubmit {
                        addTriggerWord()
                    }
                
                Button("Add") {
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

// Icon menu content for better organization
struct IconMenuContent: View {
    @Binding var selectedIcon: PromptIcon
    
    var body: some View {
        Group {
            IconMenuSection(title: "Document & Text", icons: [.documentFill, .textbox, .sealedFill], selectedIcon: $selectedIcon)
            IconMenuSection(title: "Communication", icons: [.chatFill, .messageFill, .emailFill], selectedIcon: $selectedIcon)
            IconMenuSection(title: "Professional", icons: [.meetingFill, .presentationFill, .briefcaseFill], selectedIcon: $selectedIcon)
            IconMenuSection(title: "Technical", icons: [.codeFill, .terminalFill, .gearFill], selectedIcon: $selectedIcon)
            IconMenuSection(title: "Content", icons: [.blogFill, .notesFill, .bookFill, .bookmarkFill, .pencilFill], selectedIcon: $selectedIcon)
            IconMenuSection(title: "Media & Creative", icons: [.videoFill, .micFill, .musicFill, .photoFill, .brushFill], selectedIcon: $selectedIcon)
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
            .help("Remove word")
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