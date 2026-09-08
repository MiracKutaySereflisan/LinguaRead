// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation

enum BookLanguage: String, Codable, CaseIterable, Hashable {
    case english = "en-US"
    case german  = "de-DE"
    case turkish = "tr-TR"

    var displayName: String {
        switch self {
        case .english: return "İngilizce"
        case .german:  return "Almanca"
        case .turkish: return "Türkçe"
        }
    }
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .german:  return "🇩🇪"
        case .turkish: return "🇹🇷"
        }
    }
}

enum CEFRLevel: Int, Codable, CaseIterable, Comparable {
    case a1 = 1, a2, b1, b2, c1, c2
    var label: String {
        switch self {
        case .a1: return "A1"; case .a2: return "A2"
        case .b1: return "B1"; case .b2: return "B2"
        case .c1: return "C1"; case .c2: return "C2"
        }
    }
    static func < (l: CEFRLevel, r: CEFRLevel) -> Bool { l.rawValue < r.rawValue }
}

struct Book: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var author: String
    var language: BookLanguage
    var level: CEFRLevel
    var category: String
    var fullText: String
    var isBundledSample: Bool = false
    var lastReadWordIndex: Int = 0

    var words: [String] {
        fullText.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }
    var progress: Double {
        let c = words.count
        guard c > 0 else { return 0 }
        return min(1.0, Double(lastReadWordIndex) / Double(c))
    }
}
