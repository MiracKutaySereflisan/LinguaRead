import SwiftUI

struct HomeView: View {
    @Environment(UserProfile.self) private var profile
    @Environment(LibraryStore.self) private var libraryStore

    @State private var selectedLanguage: BookLanguage = .english
    @State private var previewEntry: CatalogEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Picker("Dil", selection: $selectedLanguage) {
                        ForEach(BookLanguage.allCases, id: \.self) {
                            Text("\($0.flag) \($0.displayName)").tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    ForEach(groupedByCategory, id: \.0) { category, items in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category).font(.headline).padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(items) { entry in
                                        CatalogCard(entry: entry,
                                                    isDownloaded: isDownloaded(entry))
                                            .onTapGesture { previewEntry = entry }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(profile.name.isEmpty ? "Keşfet" : "Merhaba, \(profile.name)")
            .sheet(item: $previewEntry) { entry in
                BookPreviewSheet(entry: entry)
            }
            .onAppear { selectedLanguage = profile.selectedLanguage }
        }
    }

    private var groupedByCategory: [(String, [CatalogEntry])] {
        let items = BookCatalog.entries(for: selectedLanguage)
        let groups = Dictionary(grouping: items, by: \.category)
        return groups.sorted { $0.key < $1.key }
    }

    private func isDownloaded(_ entry: CatalogEntry) -> Bool {
        libraryStore.books.contains {
            $0.title == entry.title && $0.language == entry.language
        }
    }
}

struct CatalogCard: View {
    let entry: CatalogEntry
    let isDownloaded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [.blue.opacity(0.35), .indigo.opacity(0.5)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 160)
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "book.closed.fill")
                                .font(.title).foregroundStyle(.white)
                            Text(entry.level.label)
                                .font(.caption).bold().foregroundStyle(.white)
                        }
                    )
                if isDownloaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .background(Circle().fill(.white))
                        .offset(x: -6, y: 6)
                }
            }
            Text(entry.title)
                .font(.caption).bold()
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
            Text(entry.author)
                .font(.caption2).foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 120, alignment: .leading)
        }
    }
}
