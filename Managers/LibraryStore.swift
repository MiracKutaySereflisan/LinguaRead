import Foundation
import Observation

@Observable
final class LibraryStore {
    private(set) var books: [Book] = []

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("library.json")
    }

    init() { load() }

    // MARK: - CRUD
    func add(_ book: Book) {
        guard !books.contains(where: { $0.title == book.title && $0.language == book.language }) else { return }
        books.append(book)
        save()
    }

    func remove(_ book: Book) {
        books.removeAll { $0.id == book.id }
        save()
    }

    func updateProgress(bookID: UUID, wordIndex: Int) {
        guard let i = books.firstIndex(where: { $0.id == bookID }) else { return }
        if wordIndex > books[i].lastReadWordIndex {
            books[i].lastReadWordIndex = wordIndex
            save()
        }
    }

    func book(withID id: UUID) -> Book? {
        books.first { $0.id == id }
    }

    // MARK: - Free Tier
    func bookCount(for language: BookLanguage) -> Int {
        books.filter { $0.language == language && !$0.isBundledSample }.count
    }
    func canDownload(language: BookLanguage, isPremium: Bool) -> Bool {
        isPremium || bookCount(for: language) < AppSettings.maxBooksPerLanguage
    }
    func remainingSlots(for language: BookLanguage, isPremium: Bool) -> Int {
        isPremium ? 999 : max(0, AppSettings.maxBooksPerLanguage - bookCount(for: language))
    }

    // MARK: - Persistence
    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Book].self, from: data) else { return }
        books = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(books) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Gutenberg temizleme
    static func cleanGutenbergText(_ raw: String) -> String {
        var text = raw
        if let start = text.range(of: "*** START", options: .caseInsensitive),
           let nl = text.range(of: "\n", range: start.upperBound..<text.endIndex) {
            text = String(text[nl.upperBound...])
        }
        if let end = text.range(of: "*** END", options: .caseInsensitive) {
            text = String(text[..<end.lowerBound])
        }
        text = text.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
