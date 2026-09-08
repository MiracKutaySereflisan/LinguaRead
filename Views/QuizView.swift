import SwiftUI

struct QuizView: View {
    let language: BookLanguage

    @Environment(VocabStore.self) private var vocabStore
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [QuizQuestion] = []
    @State private var index = 0
    @State private var score = 0
    @State private var selected: String?
    @State private var finished = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if questions.isEmpty {
                    ContentUnavailableView(
                        "Quiz için yeterli kelime yok",
                        systemImage: "questionmark.circle",
                        description: Text("En az 4 kelime kaydetmen gerekiyor (\(language.displayName))")
                    )
                } else if finished {
                    VStack(spacing: 16) {
                        Image(systemName: score == questions.count ? "trophy.fill" : "checkmark.seal.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(score == questions.count ? .yellow : .green)
                        Text("\(score)/\(questions.count) doğru")
                            .font(.title).bold()
                        Text(score == questions.count ? "Mükemmel!" :
                             score > questions.count / 2 ? "Güzel gidiyorsun!" : "Tekrar dene, öğreniyorsun!")
                            .foregroundStyle(.secondary)
                        Button("Kapat") { dismiss() }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    let q = questions[index]

                    Text("Soru \(index + 1)/\(questions.count)")
                        .font(.caption).foregroundStyle(.secondary)

                    Text(q.prompt)
                        .font(.largeTitle).bold()

                    Text("Bu kelimenin Türkçesi hangisi?")
                        .foregroundStyle(.secondary)

                    VStack(spacing: 10) {
                        ForEach(q.options, id: \.self) { option in
                            Button {
                                guard selected == nil else { return }
                                selected = option
                                if option == q.correctAnswer { score += 1 }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    selected = nil
                                    if index + 1 < questions.count {
                                        index += 1
                                    } else {
                                        finished = true
                                    }
                                }
                            } label: {
                                Text(option)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonColor(option, correct: q.correctAnswer))
                                    .foregroundStyle(.primary)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
            .onAppear {
                questions = QuizGenerator.makeQuiz(from: vocabStore.words(for: language))
            }
        }
    }

    private func buttonColor(_ option: String, correct: String) -> Color {
        guard let sel = selected else { return Color(.systemGray6) }
        if option == correct { return .green.opacity(0.3) }
        if option == sel { return .red.opacity(0.3) }
        return Color(.systemGray6)
    }
}
