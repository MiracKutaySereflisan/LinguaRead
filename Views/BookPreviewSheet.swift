import SwiftUI
import AVFoundation

struct BookPreviewSheet: View {
    let entry: CatalogEntry

    @Environment(LibraryStore.self) private var libraryStore
    @Environment(AppSettings.self) private var settings
    @Environment(BookDownloader.self) private var downloader
    @Environment(\.dismiss) private var dismiss

    @State private var isDownloading = false
    @State private var errorText: String?
    @State private var isSampling = false
    @State private var showPremium = false
    @State private var sampleSynth = AVSpeechSynthesizer()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title).font(.title2).bold()
                    Text(entry.author).foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        badge("\(entry.language.flag) \(entry.language.displayName)", .blue)
                        badge(entry.level.label, .green)
                        badge(entry.category, .purple)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hakkında").font(.headline)
                    Text(entry.summary)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }

                HStack {
                    stat("clock", formatTime(entry.estimatedMinutes), "Okuma süresi")
                    Spacer()
                    stat("textformat", formatWords(entry.wordCount), "Kelime")
                    Spacer()
                    stat("chart.bar", entry.level.label, "Seviye")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button(action: toggleSample) {
                    Label(isSampling ? "Durdur" : "Özeti sesli dinle",
                          systemImage: isSampling ? "stop.circle.fill" : "speaker.wave.2.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .cornerRadius(12)
                }

                if let err = errorText {
                    Text(err).font(.caption).foregroundStyle(.red)
                }

                downloadArea
            }
            .padding(20)
        }
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showPremium) { PremiumUpgradeSheet() }
        .onDisappear { sampleSynth.stopSpeaking(at: .immediate) }
    }

    @ViewBuilder
    private var downloadArea: some View {
        let alreadyHave = libraryStore.books.contains {
            $0.title == entry.title && $0.language == entry.language
        }

        if alreadyHave {
            Label("Kitaplığında mevcut", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
        } else if isDownloading {
            HStack(spacing: 10) {
                ProgressView()
                Text("İndiriliyor...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
        } else if libraryStore.canDownload(language: entry.language, isPremium: settings.isPremium) {
            let slots = libraryStore.remainingSlots(for: entry.language, isPremium: settings.isPremium)

            Button(action: download) {
                Label("Kütüphaneme ekle", systemImage: "arrow.down.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            if !settings.isPremium && slots <= 2 {
                Text("Bu dilde \(slots) kitap hakkın kaldı")
                    .font(.caption).foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
        } else {
            Button { showPremium = true } label: {
                Label("Sınıra ulaştın — Premium'a yükselt", systemImage: "lock.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
    }

    private func badge(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption).fontWeight(.medium)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .cornerRadius(6)
    }

    private func stat(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(.blue)
            Text(value).font(.subheadline).bold()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private func toggleSample() {
        if isSampling {
            sampleSynth.stopSpeaking(at: .immediate)
            isSampling = false
            return
        }
        let utt = AVSpeechUtterance(string: entry.summary)
        utt.voice = AVSpeechSynthesisVoice(language: "tr-TR")
        utt.rate = 0.45
        sampleSynth.speak(utt)
        isSampling = true
    }

    private func download() {
        isDownloading = true
        errorText = nil
        Task {
            if let book = await downloader.download(entry: entry) {
                await MainActor.run {
                    libraryStore.add(book)
                    isDownloading = false
                    dismiss()
                }
            } else {
                await MainActor.run {
                    errorText = downloader.lastError ?? "İndirme başarısız"
                    isDownloading = false
                }
            }
        }
    }

    private func formatTime(_ min: Int) -> String {
        min >= 60 ? "\(min/60)sa \(min%60)dk" : "\(min)dk"
    }
    private func formatWords(_ n: Int) -> String {
        n >= 1000 ? String(format: "%.0fK", Double(n)/1000) : "\(n)"
    }
}
