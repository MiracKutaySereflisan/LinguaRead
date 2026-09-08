import Foundation

struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let prompt: String        // sorulan kelime
    let correctAnswer: String // doğru çeviri
    let options: [String]     // 4 seçenek (karışık)
}

enum QuizGenerator {
    /// Kelime defterinden quiz üret (aynı dilden en az 4 kelime gerekir)
    static func makeQuiz(from entries: [VocabEntry], questionCount: Int = 5) -> [QuizQuestion] {
        let pool = entries.filter { !$0.translation.isEmpty }
        guard pool.count >= 4 else { return [] }

        return pool.shuffled().prefix(questionCount).map { entry in
            var wrong = pool.filter { $0.id != entry.id }
                .shuffled().prefix(3).map(\.translation)
            wrong.append(entry.translation)
            return QuizQuestion(prompt: entry.word,
                                correctAnswer: entry.translation,
                                options: wrong.shuffled())
        }
    }
}
