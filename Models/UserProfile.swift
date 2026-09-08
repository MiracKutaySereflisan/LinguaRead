import Foundation
import Observation

@Observable
final class UserProfile {
    var name: String {
        didSet { UserDefaults.standard.set(name, forKey: "profile_name") }
    }
    var selectedLanguage: BookLanguage {
        didSet { UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "profile_lang") }
    }
    var selectedLevel: CEFRLevel {
        didSet { UserDefaults.standard.set(selectedLevel.rawValue, forKey: "profile_level") }
    }
    var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: "profile_onboarded") }
    }

    init() {
        let d = UserDefaults.standard
        name = d.string(forKey: "profile_name") ?? ""
        selectedLanguage = BookLanguage(rawValue: d.string(forKey: "profile_lang") ?? "") ?? .english
        selectedLevel = CEFRLevel(rawValue: d.integer(forKey: "profile_level")) ?? .a2
        hasOnboarded = d.bool(forKey: "profile_onboarded")
    }
}
