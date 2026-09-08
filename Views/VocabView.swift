// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct VocabView: View {
    @Environment(VocabStore.self) private var vocabStore
    @Environment(AppSettings.self) private var settings

    @State private var selectedLanguage: BookLanguage = .english

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Dil", selection: $selectedLanguage) {
                    ForEach(BookLanguage.allCases, id: \.self) {
                        Text("\($0.flag) \($0.displayName)").tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if !settings.isPremium {
                    let used = settings.vocabCount(for: selectedLanguage)
                    HStack {
                        Text("Bu ay: \(used)/\(AppSettings.maxVocabPerMonth) kelime")
                            .font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                let items = vocabStore.words(for: selectedLanguage)
                if items.isEmpty {
                    ContentUnavailableView(
                        "Henüz kelime yok",
                        systemImage: "textformat.abc",
                        description: Text("Okurken bir kelimeye uzun bas ve deftere ekle")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(items) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.word).font(.headline)
                                Text(entry.translation)
                                    .font(.subheadline).foregroundStyle(.secondary)
                                if !entry.sourceBookTitle.isEmpty {
                                    Text(entry.sourceBookTitle)
                                        .font(.caption2).foregroundStyle(.tertiary)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    vocabStore.remove(entry)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Kelimelerim")
        }
    }
}
