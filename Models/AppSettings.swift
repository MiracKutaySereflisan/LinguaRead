// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation
import Observation

@Observable
final class AppSettings {

    // MARK: - Reading / TTS
    var speechRate: Double {
        didSet { UserDefaults.standard.set(speechRate, forKey: "speechRate") }
    }
    var backgroundMusicVolume: Float {
        didSet { UserDefaults.standard.set(backgroundMusicVolume, forKey: "musicVolume") }
    }
    var darkModePreference: String { // "system" | "light" | "dark"
        didSet { UserDefaults.standard.set(darkModePreference, forKey: "themePref") }
    }

    // MARK: - Free Tier
    static let maxBooksPerLanguage = 3
    static let maxVocabPerMonth = 100

    private var vocabCounts: [String: Int] {
        didSet { UserDefaults.standard.set(vocabCounts, forKey: "vocabCounts") }
    }
    private var vocabResetMonth: Int {
        didSet { UserDefaults.standard.set(vocabResetMonth, forKey: "vocabResetMonth") }
    }

    func vocabCount(for language: BookLanguage) -> Int {
        vocabCounts[language.rawValue] ?? 0
    }
    func incrementVocab(for language: BookLanguage) {
        vocabCounts[language.rawValue, default: 0] += 1
    }
    func resetVocabIfNewMonth() {
        let m = Calendar.current.component(.month, from: Date())
        if vocabResetMonth != m {
            vocabResetMonth = m
            vocabCounts = [:]
        }
    }
    func canAddVocab(for language: BookLanguage) -> Bool {
        isPremium || vocabCount(for: language) < AppSettings.maxVocabPerMonth
    }

    // MARK: - Premium / Promo
    var isPremium: Bool {
        didSet { UserDefaults.standard.set(isPremium, forKey: "isPremiumUnlocked") }
    }
    /// Geçerli promosyon kodları. Herkese açık depoda boş bırakılır;
    /// kodlar yayına alınan yapıda tanımlanır.
    static let validPromoCodes: [String] = []

    @discardableResult
    func redeemPromoCode(_ code: String) -> Bool {
        let clean = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard AppSettings.validPromoCodes.contains(clean) else { return false }
        isPremium = true
        return true
    }

    // MARK: - Init
    init() {
        let d = UserDefaults.standard
        speechRate = d.object(forKey: "speechRate") as? Double ?? 0.45
        backgroundMusicVolume = d.object(forKey: "musicVolume") as? Float ?? 0.3
        darkModePreference = d.string(forKey: "themePref") ?? "system"
        vocabCounts = d.dictionary(forKey: "vocabCounts") as? [String: Int] ?? [:]
        vocabResetMonth = d.integer(forKey: "vocabResetMonth")
        isPremium = d.bool(forKey: "isPremiumUnlocked")
    }
}
