import SwiftUI

struct WordPopupView: View {
    let word: String
    let language: BookLanguage
    let bookTitle: String

    @Environment(VocabStore.self) private var vocabStore
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var translation = ""
    @State private var isLoading = true
    @State private var saved = false
    @State private var showPremium = false

    var body: some View {
        VStack(spacing: 20) {
            Text(word)
                .font(.largeTitle).bold()

            if isLoading {
                ProgressView("Çeviriliyor...")
            } else {
                VStack(spacing: 6) {
                    Text("Türkçe karşılık").font(.caption).foregroundStyle(.secondary)
                    Text(translation.isEmpty ? "Çeviri bulunamadı" : translation)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
            }

            if saved {
                Label("Kelime defterine eklendi", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if !settings.canAddVocab(for: language) {
                VStack(spacing: 8) {
                    Text("Bu ay \(AppSettings.maxVocabPerMonth) kelime limitine ulaştın")
                        .font(.caption).foregroundStyle(.orange)
                    Button("Premium'a yükselt") { showPremium = true }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
            } else {
                Button {
                    vocabStore.add(VocabEntry(word: word,
                                              translation: translation,
                                              language: language,
                                              sourceBookTitle: bookTitle))
                    settings.incrementVocab(for: language)
                    saved = true
                } label: {
                    Label("Kelime defterime ekle", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(isLoading)
            }

            Button("Kapat") { dismiss() }
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .presentationDetents([.fraction(0.45)])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showPremium) { PremiumUpgradeSheet() }
        .task { await translate() }
    }

    /// MyMemory ücretsiz çeviri API'si (anahtar gerektirmez)
    private func translate() async {
        let source = String(language.rawValue.prefix(2)) // "en", "de", "tr"
        guard source != "tr" else {
            translation = word   // Türkçe kitapta çeviri gerekmez
            isLoading = false
            return
        }
        guard let encoded = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mymemory.translated.net/get?q=\(encoded)&langpair=\(source)|tr") else {
            isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["responseData"] as? [String: Any],
               let text = responseData["translatedText"] as? String {
                translation = text
            }
        } catch {
            translation = ""
        }
        isLoading = false
    }
}
