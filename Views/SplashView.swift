// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.92

    private static let quotes: [(String, String)] = [
        ("Okumadan geçen gün, boşa geçmiş bir gündür.", "Mustafa Kemal Atatürk"),
        ("Bir dil bir insan, iki dil iki insandır.", "Türk atasözü"),
        ("Öğrenmenin yaşı yoktur.", "Mustafa Kemal Atatürk"),
        ("Öğrenmek, hiç durmadan devam eden bir yolculuktur.", "Konfüçyüs"),
        ("Eğitim, dünyayı değiştirmek için kullanabileceğiniz en güçlü silahtır.", "Nelson Mandela"),
        ("Yeni bir dil, yeni bir hayattır.", "Cervantes"),
        ("Bildiğin kadar değil, öğrendiğin kadar özgürsün.", "Mevlana"),
        ("Kitap okumayan insan, hiçbir şey görmeden dünyayı dolaşan insana benzer.", "Mustafa Kemal Atatürk"),
    ]

    @State private var quote: (String, String) = SplashView.quotes.randomElement()!

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.blue)
                    Text("LinguaRead")
                        .font(.largeTitle).fontWeight(.bold)
                }
                Spacer()
                VStack(spacing: 10) {
                    Text("\u{201C}\(quote.0)\u{201D}")
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                    Text("— \(quote.1)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 60)
            }
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1; scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.4)) { isActive = false }
            }
        }
    }
}
