import SwiftUI

struct ProfileView: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(VocabStore.self) private var vocabStore
    @Environment(StreakManager.self) private var streak
    @Environment(UserProfile.self) private var profile

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Streak kartı
                    HStack(spacing: 16) {
                        Image(systemName: streak.isActive ? "flame.fill" : "flame")
                            .font(.largeTitle)
                            .foregroundStyle(streak.isActive ? .orange : .gray)
                        VStack(alignment: .leading) {
                            Text("\(streak.current) gün").font(.title2).bold()
                            Text("En uzun: \(streak.longest) gün")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(streak.isActive ? Color.orange.opacity(0.1) : Color.gray.opacity(0.08))
                    .cornerRadius(12)

                    // İstatistik kartları
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                        miniStat("book.fill", "\(finishedCount)", "Bitirilen kitap")
                        miniStat("textformat.abc", "\(vocabStore.words.count)", "Kelime")
                        miniStat("clock.fill", String(format: "%.1f sa", streak.totalHours), "Toplam okuma")
                        miniStat("timer", "\(streak.todayMinutes) dk", "Bugün")
                    }

                    // Haftalık hedef
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Haftalık hedef").font(.subheadline).bold()
                            Spacer()
                            Text("\(streak.weekPages)/\(streak.weekGoal) sayfa")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        ProgressView(value: streak.weekProgress)
                            .tint(streak.weekProgress >= 1 ? .green : .blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Rozetler
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Rozetler").font(.headline)
                        LazyVGrid(columns: [.init(.flexible()), .init(.flexible()),
                                            .init(.flexible()), .init(.flexible())], spacing: 14) {
                            ForEach(badges, id: \.title) { badge in
                                VStack(spacing: 6) {
                                    Image(systemName: badge.icon)
                                        .font(.title2)
                                        .foregroundStyle(badge.earned ? badge.color : .gray.opacity(0.4))
                                    Text(badge.title)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(badge.earned ? .primary : .secondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(profile.name.isEmpty ? "Profil" : profile.name)
        }
    }

    private var finishedCount: Int {
        libraryStore.books.filter { $0.progress >= 0.97 }.count
    }

    private var badges: [(title: String, icon: String, color: Color, earned: Bool)] {
        let finished = libraryStore.books.filter { $0.progress >= 0.97 }
        let vocabCount = vocabStore.words.count
        let languagesFinished = Set(finished.map(\.language)).count
        let hasC1Plus = finished.contains { $0.level >= .c1 }

        return [
            ("İlk Adım", "figure.walk", .blue, finished.count >= 1),
            ("Kitap Kurdu", "book.fill", .indigo, finished.count >= 3),
            ("Kütüphaneci", "books.vertical.fill", .purple, finished.count >= 10),
            ("Kelime Avcısı", "target", .teal, vocabCount >= 10),
            ("Sözlük Ustası", "character.book.closed.fill", .green, vocabCount >= 50),
            ("Hafıza Devi", "brain.head.profile", .pink, vocabCount >= 200),
            ("Çok Dilli", "globe", .orange, languagesFinished >= 2),
            ("Zirve", "mountain.2.fill", .red, hasC1Plus),
        ]
    }

    private func miniStat(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(.blue)
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
