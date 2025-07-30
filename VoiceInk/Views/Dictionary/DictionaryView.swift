import SwiftUI

struct DictionaryItem: Identifiable, Hashable, Codable {
    let id: UUID
    var word: String
    var dateAdded: Date
    var isEnabled: Bool
    
    init(id: UUID = UUID(), word: String, dateAdded: Date = Date(), isEnabled: Bool = true) {
        self.id = id
        self.word = word
        self.dateAdded = dateAdded
        self.isEnabled = isEnabled
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
            updatePrompt()
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            updatePrompt()
        }
    }
    
    private func updatePrompt() {
        Task { @MainActor in
            await whisperPrompt.saveDictionaryItems(items)
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
    
    func toggleWordState(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isEnabled.toggle()
            saveItems()
        }
    }
    
    var allWords: [String] {
        items.filter { $0.isEnabled }.map { $0.word }
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
                    Text("Add words to help VoiceInk recognize them properly(154 chars max, ~25 words). Works independently of AI enhancement.")
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
                TextField("Add word to dictionary", text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13))
                    .onSubmit { addWord() }
                
                Button(action: addWord) {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .disabled(newWord.isEmpty)
                .help("Add word")
            }
            
            // Words List
            if !dictionaryManager.items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dictionary Items (\(dictionaryManager.items.count))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Toggle words on/off to optimize recognition. Disable unnecessary words to improve local AI model performance.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    ScrollView {
                        let columns = [
                            GridItem(.adaptive(minimum: 240, maximum: .infinity), spacing: 12)
                        ]
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                            ForEach(dictionaryManager.items) { item in
                                DictionaryItemView(item: item) {
                                    dictionaryManager.removeWord(item.word)
                                } onToggle: {
                                    dictionaryManager.toggleWordState(id: item.id)
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
        .alert("Dictionary", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addWord() {
        let word = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }
        
        if dictionaryManager.items.contains(where: { $0.word.lowercased() == word.lowercased() }) {
            alertMessage = "'\(word)' is already in the dictionary"
            showAlert = true
            return
        }
        
        dictionaryManager.addWord(word)
        newWord = ""
    }
}

struct DictionaryItemView: View {
    let item: DictionaryItem
    let onDelete: () -> Void
    let onToggle: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text(item.word)
                .font(.system(size: 13))
                .lineLimit(1)
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
                .help(item.isEnabled ? "Disable word" : "Enable word")
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isHovered ? .red : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.borderless)
                .help("Remove word")
            }
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
                .stroke(Color.secondary.opacity(item.isEnabled ? 0.2 : 0.1), lineWidth: 1)
        }
        .opacity(item.isEnabled ? 1 : 0.7)
        .shadow(color: Color.black.opacity(item.isEnabled ? 0.05 : 0), radius: 2, y: 1)
    }
} 
