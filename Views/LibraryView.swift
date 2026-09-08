// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct LibraryView: View {
    @Environment(LibraryStore.self) private var libraryStore
    @Environment(AppSettings.self) private var settings

    @State private var selectedLanguage: BookLanguage = .english
    @State private var showPremiumSheet = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    Picker("Dil", selection: $selectedLanguage) {
                        ForEach(BookLanguage.allCases, id: \.self) {
                            Text("\($0.flag) \($0.displayName)").tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    let slots = libraryStore.remainingSlots(for: selectedLanguage,
                                                            isPremium: settings.isPremium)
                    if slots <= 1 && !settings.isPremium {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(slots == 0 ? "Kitap sınırına ulaştın" : "1 kitap hakkın kaldı")
                                    .font(.subheadline).bold()
                                Text("Premium ile sınırsız indir")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Yükselt") { showPremiumSheet = true }
                                .buttonStyle(.borderedProminent)
                                .tint(.orange)
                                .controlSize(.small)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    if filteredBooks.isEmpty {
                        ContentUnavailableView(
                            "Henüz kitap yok",
                            systemImage: "books.vertical",
                            description: Text("Keşfet sekmesinden kitap indir")
                        )
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredBooks) { book in
                                NavigationLink(value: book.id) {
                                    LibraryCard(book: book)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        libraryStore.remove(book)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Kitaplık")
            .navigationDestination(for: UUID.self) { id in
                if let book = libraryStore.book(withID: id) {
                    ReaderView(bookID: book.id)
                }
            }
            .sheet(isPresented: $showPremiumSheet) { PremiumUpgradeSheet() }
        }
    }

    private var filteredBooks: [Book] {
        libraryStore.books.filter { $0.language == selectedLanguage }
    }
}

struct LibraryCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: [.teal.opacity(0.4), .blue.opacity(0.5)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 130)
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.title).foregroundStyle(.white)
                        Text(book.level.label)
                            .font(.caption).bold().foregroundStyle(.white)
                    }
                )
            Text(book.title).font(.subheadline).bold().lineLimit(2)
            Text(book.author).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            ProgressView(value: book.progress)
                .tint(book.progress >= 0.97 ? .green : .blue)
            Text("%\(Int(book.progress * 100))")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }
}
