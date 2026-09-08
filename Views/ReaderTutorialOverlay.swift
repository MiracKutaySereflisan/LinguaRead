// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct ReaderTutorialOverlay: View {
    @Binding var visible: Bool
    @State private var step = 0

    private let tips: [(String, String, String)] = [
        ("hand.tap", "Kelimeye dokun", "O kelimeden okumaya devam eder"),
        ("hand.tap.fill", "Uzun bas", "Sözlük ve çeviri kartı açılır"),
        ("hand.draw", "Sağa-sola kaydır", "Sayfa değiştirir"),
        ("gearshape", "Alt panel", "⚙️ ile hız, müzik ve quiz'e ulaş"),
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: tips[step].0)
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text(tips[step].1)
                    .font(.title3).bold().foregroundStyle(.white)

                Text(tips[step].2)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    ForEach(0..<tips.count, id: \.self) { i in
                        Circle()
                            .fill(i == step ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                HStack {
                    Button("Atla") { close() }
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Button(step < tips.count - 1 ? "İleri" : "Başla") {
                        if step < tips.count - 1 {
                            withAnimation { step += 1 }
                        } else { close() }
                    }
                    .bold().foregroundStyle(.white)
                }
            }
            .padding(32)
            .frame(maxWidth: 300)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }

    private func close() {
        UserDefaults.standard.set(true, forKey: "tutorialSeen")
        withAnimation { visible = false }
    }
}
