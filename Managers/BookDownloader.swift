// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation
import Observation

@Observable
final class BookDownloader {
    var isDownloading = false
    var progress: Double = 0
    var lastError: String? = nil

    /// Katalogdan kitap indir → temizle → Book döndür
    func download(entry: CatalogEntry) async -> Book? {
        guard let url = entry.textURL else {
            await MainActor.run { lastError = "İndirme adresi bulunamadı" }
            return nil
        }
        await MainActor.run { isDownloading = true; progress = 0.1; lastError = nil }
        defer { Task { @MainActor in isDownloading = false } }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run { progress = 0.7 }

            let text: String
            if entry.isWikisource {
                text = Self.extractWikisourceText(data) ?? ""
            } else {
                let raw = String(data: data, encoding: .utf8)
                    ?? String(data: data, encoding: .isoLatin1) ?? ""
                text = LibraryStore.cleanGutenbergText(raw)
            }

            guard text.count > 200 else {
                await MainActor.run { lastError = "Metin alınamadı (boş veya çok kısa)" }
                return nil
            }

            await MainActor.run { progress = 1.0 }
            return Book(title: entry.title, author: entry.author,
                        language: entry.language, level: entry.level,
                        category: entry.category, fullText: text)
        } catch {
            await MainActor.run { lastError = "İndirme hatası: \(error.localizedDescription)" }
            return nil
        }
    }

    private static func extractWikisourceText(_ data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query = json["query"] as? [String: Any],
              let pages = query["pages"] as? [String: Any],
              let first = pages.values.first as? [String: Any],
              let extract = first["extract"] as? String else { return nil }
        return extract.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
