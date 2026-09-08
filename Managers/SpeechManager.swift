// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation
import AVFoundation
import Observation

@Observable
final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {

    // MARK: - Yayınlanan durum (UI bunları izler)
    var isPlaying = false
    var currentGlobalWordIndex: Int = -1
    var currentSentenceWordRange: Range<Int>? = nil

    // MARK: - İç durum
    private let synthesizer = AVSpeechSynthesizer()
    private var sentences: [(text: String, wordRange: Range<Int>)] = []
    private var sentenceIndex = 0
    private var words: [String] = []
    private var language: BookLanguage = .english
    private var rate: Double = 0.45
    private var restartAfterCancel = false
    private var currentUtterance: AVSpeechUtterance?

    // Debounce — peş peşe basışları yut
    private var lastActionTime: Date = .distantPast
    private func canAct() -> Bool {
        let now = Date()
        guard now.timeIntervalSince(lastActionTime) > 0.3 else { return false }
        lastActionTime = now
        return true
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Hazırlık
    func prepare(book: Book, rate: Double) {
        stop()
        words = book.words
        language = book.language
        self.rate = rate
        buildSentences(from: book.fullText)
    }

    private func buildSentences(from text: String) {
        sentences = []
        var wordCursor = 0
        var current: [String] = []
        var startIndex = 0
        for w in text.split(whereSeparator: { $0.isWhitespace }).map(String.init) {
            if current.isEmpty { startIndex = wordCursor }
            current.append(w)
            wordCursor += 1
            if let last = w.unicodeScalars.last,
               CharacterSet(charactersIn: ".!?…").contains(last) || current.count >= 40 {
                sentences.append((current.joined(separator: " "), startIndex..<wordCursor))
                current = []
            }
        }
        if !current.isEmpty {
            sentences.append((current.joined(separator: " "), startIndex..<wordCursor))
        }
    }

    // MARK: - Kontroller
    func startReading(fromGlobalWordIndex index: Int) {
        guard canAct(), !sentences.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)
        sentenceIndex = sentences.firstIndex { $0.wordRange.contains(max(0, index)) } ?? 0
        isPlaying = true
        speakCurrentSentence()
    }

    func pause() {
        guard canAct() else { return }
        isPlaying = false
        synthesizer.stopSpeaking(at: .immediate)
    }

    func stop() {
        isPlaying = false
        restartAfterCancel = false
        currentUtterance = nil
        synthesizer.stopSpeaking(at: .immediate)
        currentGlobalWordIndex = -1
        currentSentenceWordRange = nil
    }

    func setRate(_ newRate: Double) {
        rate = newRate
        guard isPlaying else { return }
        restartAfterCancel = true
        synthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Konuşma
    private func speakCurrentSentence() {
        guard sentenceIndex < sentences.count else {
            isPlaying = false
            return
        }
        let s = sentences[sentenceIndex]
        let utt = AVSpeechUtterance(string: s.text)
        utt.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        utt.rate = Float(rate)
        currentUtterance = utt
        currentSentenceWordRange = s.wordRange
        synthesizer.speak(utt)
    }

    // MARK: - Delegate
    func speechSynthesizer(_ s: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        guard utterance === currentUtterance,
              sentenceIndex < sentences.count else { return }
        let sentence = sentences[sentenceIndex]
        let ns = sentence.text as NSString
        guard characterRange.location < ns.length else { return }
        let prefix = ns.substring(to: characterRange.location)
        let wordOffset = prefix.split(whereSeparator: { $0.isWhitespace }).count
        let newIndex = sentence.wordRange.lowerBound + wordOffset
        DispatchQueue.main.async { [weak self] in
            guard let self, utterance === self.currentUtterance else { return }
            self.currentGlobalWordIndex = min(newIndex, sentence.wordRange.upperBound - 1)
        }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard utterance === currentUtterance else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isPlaying else { return }
            self.sentenceIndex += 1
            self.speakCurrentSentence()
        }
    }

    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard utterance === currentUtterance else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.restartAfterCancel {
                self.restartAfterCancel = false
                self.speakCurrentSentence()
            }
        }
    }
}
