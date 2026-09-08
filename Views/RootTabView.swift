// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Keşfet", systemImage: "sparkles") }
            LibraryView()
                .tabItem { Label("Kitaplık", systemImage: "books.vertical") }
            VocabView()
                .tabItem { Label("Kelimelerim", systemImage: "textformat.abc") }
            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.circle") }
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
        }
    }
}
