import SwiftUI

struct PremiumUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let features: [(String, String)] = [
        ("books.vertical.fill", "Sınırsız kitap indirme"),
        ("textformat.abc", "Sınırsız kelime kaydetme"),
        ("brain.head.profile", "Gelişmiş quiz özellikleri"),
        ("chart.line.uptrend.xyaxis", "Detaylı ilerleme takibi"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.orange)
                    Text("LinguaRead Premium")
                        .font(.title2).bold()
                    Text("Okuma deneyimini sınırsız yap")
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(features, id: \.1) { icon, text in
                        HStack(spacing: 12) {
                            Image(systemName: icon)
                                .foregroundStyle(.orange)
                                .frame(width: 24)
                            Text(text)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {}) {
                        VStack(spacing: 2) {
                            Text("Aylık plan").font(.headline)
                            Text("₺149,99 / ay").font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }

                    Button(action: {}) {
                        VStack(spacing: 2) {
                            HStack {
                                Text("Yıllık plan").font(.headline)
                                Text("En iyi değer")
                                    .font(.caption2)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundStyle(.green)
                                    .cornerRadius(4)
                            }
                            Text("₺999,99 / yıl — %44 indirim").font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange, lineWidth: 1))
                    }

                    Text("Promosyon kodun mu var? Ayarlar → Premium bölümünden girebilirsin.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}
