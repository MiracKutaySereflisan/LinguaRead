import Foundation

struct VocabEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var translation: String
    var language: BookLanguage
    var addedAt: Date = Date()
    var sourceBookTitle: String = ""
}
