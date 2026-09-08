import Foundation
import Observation

@Observable
final class VocabStore {
    private(set) var words: [VocabEntry] = []

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("vocab.json")
    }

    init() { load() }

    func add(_ entry: VocabEntry) {
        guard !words.contains(where: {
            $0.word.lowercased() == entry.word.lowercased() && $0.language == entry.language
        }) else { return }
        words.insert(entry, at: 0)
        save()
    }

    func remove(_ entry: VocabEntry) {
        words.removeAll { $0.id == entry.id }
        save()
    }

    func words(for language: BookLanguage) -> [VocabEntry] {
        words.filter { $0.language == language }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([VocabEntry].self, from: data) else { return }
        words = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(words) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
