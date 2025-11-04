import SwiftUI

struct DictionaryItem: Identifiable, Hashable, Codable {
    let id: UUID
    var word: String
    var dateAdded: Date
<<<<<<< HEAD
    var isEnabled: Bool
    
    init(id: UUID = UUID(), word: String, dateAdded: Date = Date(), isEnabled: Bool = true) {
        self.id = id
        self.word = word
        self.dateAdded = dateAdded
        self.isEnabled = isEnabled
=======
    
    init(id: UUID = UUID(), word: String, dateAdded: Date = Date()) {
        self.id = id
        self.word = word
        self.dateAdded = dateAdded
    }
    
    // Legacy support for decoding old data with isEnabled property
    private enum CodingKeys: String, CodingKey {
        case id, word, dateAdded, isEnabled
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        // Ignore isEnabled during decoding - all items are enabled by default now
        _ = try? container.decodeIfPresent(Bool.self, forKey: .isEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(word, forKey: .word)
        try container.encode(dateAdded, forKey: .dateAdded)
        // Don't encode isEnabled anymore
>>>>>>> upstream/main
    }
}

class DictionaryManager: ObservableObject {
    @Published var items: [DictionaryItem] = []
    private let saveKey = "CustomDictionaryItems"
    private let whisperPrompt: WhisperPrompt
    
    init(whisperPrompt: WhisperPrompt) {
        self.whisperPrompt = whisperPrompt
        loadItems()
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
        if let savedItems = try? JSONDecoder().decode([DictionaryItem].self, from: data) {
            items = savedItems.sorted(by: { $0.dateAdded > $1.dateAdded })
<<<<<<< HEAD
            updatePrompt()
=======
>>>>>>> upstream/main
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
<<<<<<< HEAD
            updatePrompt()
        }
    }
    
    private func updatePrompt() {
        Task { @MainActor in
            await whisperPrompt.saveDictionaryItems(items)
=======
>>>>>>> upstream/main
        }
    }
    
    func addWord(_ word: String) {
        let normalizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !items.contains(where: { $0.word.lowercased() == normalizedWord.lowercased() }) else {
            return
        }
        
        let newItem = DictionaryItem(word: normalizedWord)
        items.insert(newItem, at: 0)
        saveItems()
    }
    
    func removeWord(_ word: String) {
        items.removeAll(where: { $0.word == word })
        saveItems()
    }
    
<<<<<<< HEAD
    func toggleWordState(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isEnabled.toggle()
            saveItems()
        }
    }
    
    var allWords: [String] {
        items.filter { $0.isEnabled }.map { $0.word }
=======
    var allWords: [String] {
        items.map { $0.word }
>>>>>>> upstream/main
    }
}

struct DictionaryView: View {
    @StateObject private var dictionaryManager: DictionaryManager
    @ObservedObject var whisperPrompt: WhisperPrompt
    @State private var newWord = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(whisperPrompt: WhisperPrompt) {
        self.whisperPrompt = whisperPrompt
        _dictionaryManager = StateObject(wrappedValue: DictionaryManager(whisperPrompt: whisperPrompt))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Information Section
            GroupBox {
                Label {
<<<<<<< HEAD
Text(NSLocalizedString("Add words to help VoiceInk recognize them properly(154 chars max, ~25 words). Works independently of AI enhancement.", comment: "Add words to help VoiceInk recognize them properly(154 chars max, ~25 words). Works independently of AI enhancement."))
=======
                    Text("Add words to help VoiceInk recognize them properly. (Requires AI enhancement)")
>>>>>>> upstream/main
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // Input Section
            HStack(spacing: 8) {
<<<<<<< HEAD
TextField(NSLocalizedString("Add word to dictionary", comment: "Add word to dictionary"), text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .onSubmit { addWord() }
                
                Button(action: addWord) {
=======
                TextField("Add word to dictionary", text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .onSubmit { addWords() }
                
                Button(action: addWords) {
>>>>>>> upstream/main
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .disabled(newWord.isEmpty)
<<<<<<< HEAD
.help(NSLocalizedString("Add word", comment: "Add word"))
=======
                .help("Add word")
>>>>>>> upstream/main
            }
            
            // Words List
            if !dictionaryManager.items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dictionary Items (\(dictionaryManager.items.count))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
<<<<<<< HEAD
Text(NSLocalizedString("Toggle words on/off to optimize recognition. Disable unnecessary words to improve local AI model performance.", comment: "Toggle words on/off to optimize recognition. Disable unnecessary words to improve local AI model performance."))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
=======
>>>>>>> upstream/main
                    ScrollView {
                        let columns = [
                            GridItem(.adaptive(minimum: 240, maximum: .infinity), spacing: 12)
                        ]
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                            ForEach(dictionaryManager.items) { item in
                                DictionaryItemView(item: item) {
                                    dictionaryManager.removeWord(item.word)
<<<<<<< HEAD
                                } onToggle: {
                                    dictionaryManager.toggleWordState(id: item.id)
=======
>>>>>>> upstream/main
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.top, 4)
            }
        }
        .padding()
<<<<<<< HEAD
.alert(NSLocalizedString("Dictionary", comment: "Dictionary"), isPresented: $showAlert) {
                            Button(NSLocalizedString("OK", comment: "OK"), role: .cancel) {}
=======
        .alert("Dictionary", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
>>>>>>> upstream/main
        } message: {
            Text(alertMessage)
        }
    }
    
<<<<<<< HEAD
    private func addWord() {
        let word = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }
        
        if dictionaryManager.items.contains(where: { $0.word.lowercased() == word.lowercased() }) {
            alertMessage = "'\(word)' is already in the dictionary"
            showAlert = true
            return
        }
        
        dictionaryManager.addWord(word)
=======
    private func addWords() {
        let input = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        
        let parts = input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !parts.isEmpty else { return }
        
        if parts.count == 1, let word = parts.first {
            if dictionaryManager.items.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                alertMessage = "'\(word)' is already in the dictionary"
                showAlert = true
                return
            }
            dictionaryManager.addWord(word)
            newWord = ""
            return
        }
        
        for word in parts {
            let lower = word.lowercased()
            if !dictionaryManager.items.contains(where: { $0.word.lowercased() == lower }) {
                dictionaryManager.addWord(word)
            }
        }
>>>>>>> upstream/main
        newWord = ""
    }
}

struct DictionaryItemView: View {
    let item: DictionaryItem
    let onDelete: () -> Void
<<<<<<< HEAD
    let onToggle: () -> Void
=======
>>>>>>> upstream/main
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text(item.word)
                .font(.system(size: 13))
                .lineLimit(1)
<<<<<<< HEAD
                .foregroundColor(item.isEnabled ? .primary : .secondary)
            
            Spacer(minLength: 8)
            
            HStack(spacing: 4) {
                Button(action: onToggle) {
                    Image(systemName: item.isEnabled ? "checkmark.circle.fill" : "circle")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(item.isEnabled ? .green : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.borderless)
.help(item.isEnabled ? "Disable word" : NSLocalizedString("Enable word", comment: "Enable word"))
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isHovered ? .red : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.borderless)
.help(NSLocalizedString("Remove word", comment: "Remove word"))
            }
=======
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
<<<<<<< HEAD
                .stroke(Color.secondary.opacity(item.isEnabled ? 0.2 : 0.1), lineWidth: 1)
        }
        .opacity(item.isEnabled ? 1 : 0.7)
        .shadow(color: Color.black.opacity(item.isEnabled ? 0.05 : 0), radius: 2, y: 1)
=======
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
>>>>>>> upstream/main
    }
} 
