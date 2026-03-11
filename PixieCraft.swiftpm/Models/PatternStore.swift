import SwiftUI
import Foundation

class PatternStore: ObservableObject {
    
    @Published var patterns: [CrochetPattern] = []
    @Published var completedCrafts: [CompletedCraft] = []
    
    private static let patternsFileName = "pixiecraft_patterns.json"
    private static let craftsFileName = "pixiecraft_crafts.json"
    
    init() {
        loadPatterns()
        loadCrafts()
    }
    
    
    func add(_ pattern: CrochetPattern) {
        patterns.insert(pattern, at: 0) // newest first
        savePatterns()
    }
    
    func delete(at offsets: IndexSet) {
        patterns.remove(atOffsets: offsets)
        savePatterns()
    }
    
    func delete(id: UUID) {
        patterns.removeAll { $0.id == id }
        savePatterns()
    }
    
    func update(_ pattern: CrochetPattern) {
        if let idx = patterns.firstIndex(where: { $0.id == pattern.id }) {
            patterns[idx] = pattern
            savePatterns()
        }
    }
    
    
    func addCraft(_ craft: CompletedCraft) {
        completedCrafts.insert(craft, at: 0) // newest first
        saveCrafts()
    }
    
    func deleteCraft(id: UUID) {
        completedCrafts.removeAll { $0.id == id }
        saveCrafts()
    }
    
    func updateCraft(_ craft: CompletedCraft) {
        if let index = completedCrafts.firstIndex(where: { $0.id == craft.id }) {
            completedCrafts[index] = craft
            saveCrafts()
        }
    }
    
    func deleteCrafts(at offsets: IndexSet) {
        completedCrafts.remove(atOffsets: offsets)
        saveCrafts()
    }
    
    
    private var patternsFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(Self.patternsFileName)
    }
    
    private func savePatterns() {
        do {
            let data = try JSONEncoder().encode(patterns)
            try data.write(to: patternsFileURL, options: .atomic)
        } catch {
            #if DEBUG
            print("PatternStore save error: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func loadPatterns() {
        guard FileManager.default.fileExists(atPath: patternsFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: patternsFileURL)
            patterns = try JSONDecoder().decode([CrochetPattern].self, from: data)
        } catch {
            #if DEBUG
            print("PatternStore load error: \(error.localizedDescription)")
            #endif
        }
    }
    
    
    private var craftsFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(Self.craftsFileName)
    }
    
    private func saveCrafts() {
        do {
            let data = try JSONEncoder().encode(completedCrafts)
            try data.write(to: craftsFileURL, options: .atomic)
        } catch {
            #if DEBUG
            print("CompletedCrafts save error: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func loadCrafts() {
        guard FileManager.default.fileExists(atPath: craftsFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: craftsFileURL)
            completedCrafts = try JSONDecoder().decode([CompletedCraft].self, from: data)
        } catch {
            #if DEBUG
            print("CompletedCrafts load error: \(error.localizedDescription)")
            #endif
        }
    }
}
