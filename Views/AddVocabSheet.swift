// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

/// Elle kelime ekleme sayfası (WordPopupView otomatik ekleme yapar,
/// bu sheet manuel giriş içindir)
struct AddVocabSheet: View {
    let language: BookLanguage
    let bookTitle: String

    @Environment(VocabStore.self) private var vocabStore
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var word = ""
    @State private var translation = ""
    @State private var showPremiumSheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Kelime") {
                    TextField("Kelime", text: $word)
                        .autocorrectionDisabled()
                    TextField("Türkçe karşılığı", text: $translation)
                }

                Section {
                    if !settings.canAddVocab(for: language) {
                        VStack(spacing: 8) {
                            Text("Bu ay \(AppSettings.maxVocabPerMonth) kelime limitine ulaştın")
                                .font(.caption).foregroundStyle(.orange)
                            Button("Premium'a yükselt") { showPremiumSheet = true }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Button("Kaydet") {
                            vocabStore.add(VocabEntry(word: word,
                                                      translation: translation,
                                                      language: language,
                                                      sourceBookTitle: bookTitle))
                            settings.incrementVocab(for: language)
                            dismiss()
                        }
                        .disabled(word.isEmpty || translation.isEmpty)
                    }
                }
            }
            .navigationTitle("Kelime ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
            .sheet(isPresented: $showPremiumSheet) { PremiumUpgradeSheet() }
        }
    }
}
