// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct ReaderView: View {
    let bookID: UUID

    @Environment(LibraryStore.self) private var libraryStore
    @Environment(AppSettings.self) private var settings
    @Environment(StreakManager.self) private var streak
    @Environment(MusicPlayer.self) private var music

    @State private var speech = SpeechManager()
    @State private var currentPage = 0
    @State private var showPanel = false
    @State private var showRatePopover = false
    @State private var sliderRate: Double = 0.45
    @State private var showQuiz = false
    @State private var readStart: Date?
    @State private var wordPopup: WordPopupTarget?
    @State private var showTutorial = !UserDefaults.standard.bool(forKey: "tutorialSeen")

    private let wordsPerPage = 90

    private var book: Book? { libraryStore.book(withID: bookID) }
    private var words: [String] { book?.words ?? [] }
    private var pageCount: Int { max(1, (words.count + wordsPerPage - 1) / wordsPerPage) }
    private var pageRange: Range<Int> {
        let start = currentPage * wordsPerPage
        return start..<min(start + wordsPerPage, words.count)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            // — Sayfa içeriği: animasyonsuz, "şak" diye geçer —
            VStack {
                WrappingWordsView(
                    words: words[safe: pageRange],
                    globalOffset: pageRange.lowerBound,
                    highlightIndex: speech.currentGlobalWordIndex,
                    sentenceRange: speech.currentSentenceWordRange,
                    onTap: { globalIndex in
                        speech.startReading(fromGlobalWordIndex: globalIndex)
                        libraryStore.updateProgress(bookID: bookID, wordIndex: globalIndex)
                    },
                    onLongPress: { word in
                        wordPopup = WordPopupTarget(word: word)
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .transaction { $0.animation = nil }   // sayfa/kelime alanında animasyon YOK

                Spacer(minLength: 90)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        if value.translation.width < -40 { goToPage(currentPage + 1) }
                        else if value.translation.width > 40 { goToPage(currentPage - 1) }
                    }
            )
            .onTapGesture {
                if showPanel { showPanel = false }
            }

            controlBar
        }
        .navigationTitle(book?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard let book else { return }
            sliderRate = settings.speechRate
            speech.prepare(book: book, rate: settings.speechRate)
            currentPage = min(book.lastReadWordIndex / wordsPerPage, pageCount - 1)
            readStart = Date()
        }
        .onDisappear {
            speech.stop()
            if let s = readStart {
                streak.addTime(seconds: Int(Date().timeIntervalSince(s)))
            }
            if speech.currentGlobalWordIndex > 0 {
                libraryStore.updateProgress(bookID: bookID,
                                            wordIndex: speech.currentGlobalWordIndex)
            }
        }
        .onChange(of: speech.currentGlobalWordIndex) { _, newIndex in
            // Okuma sayfa sonunu geçtiyse sayfayı otomatik ilerlet
            guard newIndex >= 0 else { return }
            let page = newIndex / wordsPerPage
            if page != currentPage { goToPage(page, fromSpeech: true) }
        }
        .sheet(item: $wordPopup) { target in
            WordPopupView(word: target.word,
                          language: book?.language ?? .english,
                          bookTitle: book?.title ?? "")
        }
        .sheet(isPresented: $showQuiz) {
            QuizView(language: book?.language ?? .english)
        }
        .overlay {
            if showTutorial {
                ReaderTutorialOverlay(visible: $showTutorial)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Alt panel
    @ViewBuilder
    private var controlBar: some View {
        VStack(spacing: 8) {
            if showPanel {
                HStack(spacing: 20) {
                    Button { goToPage(currentPage - 1) } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(currentPage == 0)

                    Text("\(currentPage + 1)/\(pageCount)")
                        .font(.caption).monospacedDigit()
                        .foregroundStyle(.secondary)

                    Button { goToPage(currentPage + 1) } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(currentPage >= pageCount - 1)

                    Divider().frame(height: 20)

                    Button { showRatePopover = true } label: {
                        Image(systemName: "speedometer")
                    }
                    .popover(isPresented: $showRatePopover) {
                        VStack(spacing: 10) {
                            Text("Okuma hızı: \(String(format: "%.2f", sliderRate))")
                                .font(.caption)
                            Slider(value: $sliderRate, in: 0.25...0.70) { editing in
                                if !editing {
                                    settings.speechRate = sliderRate
                                    speech.setRate(sliderRate)
                                }
                            }
                            .frame(width: 200)
                        }
                        .padding()
                        .presentationCompactAdaptation(.popover)
                    }

                    musicMenu

                    Button { showQuiz = true } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                .font(.title3)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }

            HStack(spacing: 24) {
                Button { showPanel.toggle() } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                }

                Button {
                    if speech.isPlaying {
                        speech.pause()
                    } else {
                        let resumeAt = max(speech.currentGlobalWordIndex,
                                           book?.lastReadWordIndex ?? 0)
                        speech.startReading(fromGlobalWordIndex: max(0, resumeAt))
                    }
                } label: {
                    Image(systemName: speech.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.bottom, 10)
        }
    }

    private var musicMenu: some View {
        Menu {
            ForEach(MusicPlayer.tracks, id: \.file) { track in
                Button(track.name) {
                    music.play(file: track.file, volume: settings.backgroundMusicVolume)
                }
            }
            if music.currentTrack != nil {
                Button("Müziği durdur", role: .destructive) { music.stop() }
            }
        } label: {
            Image(systemName: music.currentTrack == nil ? "music.note" : "music.note.list")
        }
    }

    // MARK: - Sayfa geçişi (ANİMASYONSUZ)
    private func goToPage(_ page: Int, fromSpeech: Bool = false) {
        let target = min(max(0, page), pageCount - 1)
        guard target != currentPage else { return }
        currentPage = target
        if !fromSpeech {
            streak.recordPage()
        }
    }
}

struct WordPopupTarget: Identifiable {
    let id = UUID()
    let word: String
}

// Güvenli aralık erişimi
extension Array {
    subscript(safe range: Range<Int>) -> ArraySlice<Element> {
        let lower = Swift.max(0, range.lowerBound)
        let upper = Swift.min(count, range.upperBound)
        guard lower < upper else { return [] }
        return self[lower..<upper]
    }
}
