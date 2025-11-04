import SwiftUI

<<<<<<< HEAD
=======
extension String: Identifiable {
    public var id: String { self }
}

enum SortMode: String {
    case originalAsc = "originalAsc"
    case originalDesc = "originalDesc"
    case replacementAsc = "replacementAsc"
    case replacementDesc = "replacementDesc"
}

enum SortColumn {
    case original
    case replacement
}

>>>>>>> upstream/main
class WordReplacementManager: ObservableObject {
    @Published var replacements: [String: String] {
        didSet {
            UserDefaults.standard.set(replacements, forKey: "wordReplacements")
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "IsWordReplacementEnabled")
        }
    }
    
    init() {
        self.replacements = UserDefaults.standard.dictionary(forKey: "wordReplacements") as? [String: String] ?? [:]
        self.isEnabled = UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled")
    }
    
    func addReplacement(original: String, replacement: String) {
<<<<<<< HEAD
        replacements[original] = replacement
=======
        // Preserve comma-separated originals as a single entry
        let trimmed = original.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        replacements[trimmed] = replacement
>>>>>>> upstream/main
    }
    
    func removeReplacement(original: String) {
        replacements.removeValue(forKey: original)
    }
<<<<<<< HEAD
=======
    
    func updateReplacement(oldOriginal: String, newOriginal: String, newReplacement: String) {
        // Replace old key with the new comma-preserved key
        replacements.removeValue(forKey: oldOriginal)
        let trimmed = newOriginal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        replacements[trimmed] = newReplacement
    }
>>>>>>> upstream/main
}

struct WordReplacementView: View {
    @StateObject private var manager = WordReplacementManager()
    @State private var showAddReplacementModal = false
    @State private var showAlert = false
<<<<<<< HEAD
    @State private var alertMessage = ""
=======
    @State private var editingOriginal: String? = nil
    
    @State private var alertMessage = ""
    @State private var sortMode: SortMode = .originalAsc
    
    init() {
        if let savedSort = UserDefaults.standard.string(forKey: "wordReplacementSortMode"),
           let mode = SortMode(rawValue: savedSort) {
            _sortMode = State(initialValue: mode)
        }
    }
    
    private var sortedReplacements: [(key: String, value: String)] {
        let pairs = Array(manager.replacements)
        
        switch sortMode {
        case .originalAsc:
            return pairs.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
        case .originalDesc:
            return pairs.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedDescending }
        case .replacementAsc:
            return pairs.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending }
        case .replacementDesc:
            return pairs.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedDescending }
        }
    }
    
    private func toggleSort(for column: SortColumn) {
        switch column {
        case .original:
            sortMode = (sortMode == .originalAsc) ? .originalDesc : .originalAsc
        case .replacement:
            sortMode = (sortMode == .replacementAsc) ? .replacementDesc : .replacementAsc
        }
        UserDefaults.standard.set(sortMode.rawValue, forKey: "wordReplacementSortMode")
    }
>>>>>>> upstream/main
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Info Section with Toggle
            GroupBox {
                HStack {
                    Label {
<<<<<<< HEAD
Text(NSLocalizedString("Define word replacements to automatically replace specific words or phrases", comment: "Define word replacements to automatically replace specific words or phrases"))
=======
                        Text("Define word replacements to automatically replace specific words or phrases")
>>>>>>> upstream/main
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(alignment: .leading)
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
<<<<<<< HEAD
Toggle(NSLocalizedString("Enable", comment: "Enable"), isOn: $manager.isEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
.help(NSLocalizedString("Enable automatic word replacement after transcription", comment: "Enable automatic word replacement after transcription"))
=======
                    Toggle("Enable", isOn: $manager.isEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .help("Enable automatic word replacement after transcription")
>>>>>>> upstream/main
                }
            }
            
            VStack(spacing: 0) {
<<<<<<< HEAD
                // Header with action button
                HStack {
Text(NSLocalizedString("Word Replacements", comment: "Word Replacements"))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: { showAddReplacementModal = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    .help(NSLocalizedString("Add new replacement", comment: "Add new replacement"))
=======
                HStack(spacing: 16) {
                    Button(action: { toggleSort(for: .original) }) {
                        HStack(spacing: 4) {
                            Text("Original")
                                .font(.headline)
                            
                            if sortMode == .originalAsc || sortMode == .originalDesc {
                                Image(systemName: sortMode == .originalAsc ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                        .frame(width: 20)
                    
                    Button(action: { toggleSort(for: .replacement) }) {
                        HStack(spacing: 4) {
                            Text("Replacement")
                                .font(.headline)
                            
                            if sortMode == .replacementAsc || sortMode == .replacementDesc {
                                Image(systemName: sortMode == .replacementAsc ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    HStack(spacing: 8) {
                        Button(action: { showAddReplacementModal = true }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.borderless)
                    }
                    .frame(width: 60)
>>>>>>> upstream/main
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.controlBackgroundColor))
                
                Divider()
                
                // Content
                if manager.replacements.isEmpty {
                    EmptyStateView(showAddModal: $showAddReplacementModal)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
<<<<<<< HEAD
                            ForEach(Array(manager.replacements.keys.sorted()), id: \.self) { original in
                                ReplacementRow(
                                    original: original,
                                    replacement: manager.replacements[original] ?? "",
                                    onDelete: { manager.removeReplacement(original: original) }
                                )
                                
                                if original != manager.replacements.keys.sorted().last {
=======
                            ForEach(Array(sortedReplacements.enumerated()), id: \.offset) { index, pair in
                                ReplacementRow(
                                    original: pair.key,
                                    replacement: pair.value,
                                    onDelete: { manager.removeReplacement(original: pair.key) },
                                    onEdit: { editingOriginal = pair.key }
                                )
                                
                                if index != sortedReplacements.count - 1 {
>>>>>>> upstream/main
                                    Divider()
                                        .padding(.leading, 32)
                                }
                            }
                        }
                        .background(Color(.controlBackgroundColor))
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showAddReplacementModal) {
            AddReplacementSheet(manager: manager)
        }
<<<<<<< HEAD
=======
        // Edit existing replacement
        .sheet(item: $editingOriginal) { original in
            EditReplacementSheet(manager: manager, originalKey: original)
        }
        
>>>>>>> upstream/main
    }
}

struct EmptyStateView: View {
    @Binding var showAddModal: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.word.spacing")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
<<<<<<< HEAD
Text(NSLocalizedString("No Replacements", comment: "No Replacements"))
                .font(.headline)
            
Text(NSLocalizedString("Add word replacements to automatically replace text during AI enhancement.", comment: "Add word replacements to automatically replace text during AI enhancement."))
=======
            Text("No Replacements")
                .font(.headline)
            
            Text("Add word replacements to automatically replace text.")
>>>>>>> upstream/main
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
            
<<<<<<< HEAD
Button(NSLocalizedString("Add Replacement", comment: "Add Replacement")) {
=======
            Button("Add Replacement") {
>>>>>>> upstream/main
                showAddModal = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddReplacementSheet: View {
    @ObservedObject var manager: WordReplacementManager
    @Environment(\.dismiss) private var dismiss
    @State private var originalWord = ""
    @State private var replacementWord = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
<<<<<<< HEAD
                Button(NSLocalizedString("Cancel", comment: "Cancel button"), role: .cancel) {
=======
                Button("Cancel", role: .cancel) {
>>>>>>> upstream/main
                    dismiss()
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
<<<<<<< HEAD
Text(NSLocalizedString("Add Word Replacement", comment: "Add Word Replacement"))
=======
                Text("Add Word Replacement")
>>>>>>> upstream/main
                    .font(.headline)
                
                Spacer()
                
<<<<<<< HEAD
                Button(NSLocalizedString("Add", comment: "Add button")) {
=======
                Button("Add") {
>>>>>>> upstream/main
                    addReplacement()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(originalWord.isEmpty || replacementWord.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(CardBackground(isSelected: false))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Description
<<<<<<< HEAD
Text(NSLocalizedString("Define a word or phrase to be automatically replaced during AI enhancement.", comment: "Define a word or phrase to be automatically replaced during AI enhancement."))
=======
                    Text("Define a word or phrase to be automatically replaced.")
>>>>>>> upstream/main
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Form Content
                    VStack(spacing: 16) {
                        // Original Text Section
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Original Text")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
<<<<<<< HEAD
                                Text(NSLocalizedString(NSLocalizedString("Required", comment: "Required"), comment: "Required"))
=======
                                Text("Required")
>>>>>>> upstream/main
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
<<<<<<< HEAD
TextField(NSLocalizedString("Enter word or phrase to replace", comment: "Enter word or phrase to replace"), text: $originalWord)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
=======
                            TextField("Enter word or phrase to replace (use commas for multiple)", text: $originalWord)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                            Text("Separate multiple originals with commas, e.g. Voicing, Voice ink, Voiceing")
                                .font(.caption)
                                .foregroundColor(.secondary)
>>>>>>> upstream/main
                        }
                        .padding(.horizontal)
                        
                        // Replacement Text Section
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
<<<<<<< HEAD
Text(NSLocalizedString("Replacement Text", comment: "Replacement Text"))
=======
                                Text("Replacement Text")
>>>>>>> upstream/main
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Required")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextEditor(text: $replacementWord)
                                .font(.body)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.textBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(.separatorColor), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Example Section
                    VStack(alignment: .leading, spacing: 8) {
<<<<<<< HEAD
                        Text(NSLocalizedString("Example", comment: "Example"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
Text(NSLocalizedString("Original:", comment: "Original:"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(NSLocalizedString("my website link", comment: "my website link"))
=======
                        Text("Examples")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Single original -> replacement
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Original:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("my website link")
>>>>>>> upstream/main
                                    .font(.callout)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
<<<<<<< HEAD
Text(NSLocalizedString("Replacement:", comment: "Replacement:"))
=======
                                Text("Replacement:")
>>>>>>> upstream/main
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("https://tryvoiceink.com")
                                    .font(.callout)
                            }
                        }
<<<<<<< HEAD
=======
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)

                        // Comma-separated originals -> single replacement
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Original:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Voicing, Voice ink, Voiceing")
                                    .font(.callout)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Replacement:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("VoiceInk")
                                    .font(.callout)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
>>>>>>> upstream/main
                        .padding(12)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
        }
<<<<<<< HEAD
        .frame(width: 460, height: 480)
=======
        .frame(width: 460, height: 520)
>>>>>>> upstream/main
    }
    
    private func addReplacement() {
        let original = originalWord
        let replacement = replacementWord
        
<<<<<<< HEAD
        guard !original.isEmpty && !replacement.isEmpty else { return }
=======
        // Validate that at least one non-empty token exists
        let tokens = original
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty && !replacement.isEmpty else { return }
>>>>>>> upstream/main
        
        manager.addReplacement(original: original, replacement: replacement)
        dismiss()
    }
}

struct ReplacementRow: View {
    let original: String
    let replacement: String
    let onDelete: () -> Void
<<<<<<< HEAD
=======
    let onEdit: () -> Void
>>>>>>> upstream/main
    
    var body: some View {
        HStack(spacing: 16) {
            // Original Text Container
            HStack {
                Text(original)
                    .font(.body)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity)
            
            // Arrow
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
            
            // Replacement Text Container
            HStack {
                Text(replacement)
                    .font(.body)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity)
            
<<<<<<< HEAD
=======
            // Edit Button
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .help("Edit replacement")
            
>>>>>>> upstream/main
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.red)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
<<<<<<< HEAD
.help(NSLocalizedString("Remove replacement", comment: "Remove replacement"))
=======
            .help("Remove replacement")
>>>>>>> upstream/main
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(Color(.controlBackgroundColor))
    }
} 