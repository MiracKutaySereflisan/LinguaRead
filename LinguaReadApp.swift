import SwiftUI

@main
struct LinguaReadApp: App {
    @State private var libraryStore = LibraryStore()
    @State private var vocabStore = VocabStore()
    @State private var settings = AppSettings()
    @State private var userProfile = UserProfile()
    @State private var downloader = BookDownloader()
    @State private var streak = StreakManager()
    @State private var music = MusicPlayer()

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if userProfile.hasOnboarded {
                        RootTabView()
                    } else {
                        OnboardingView()
                    }
                }
                .environment(libraryStore)
                .environment(vocabStore)
                .environment(settings)
                .environment(userProfile)
                .environment(downloader)
                .environment(streak)
                .environment(music)

                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(
                settings.darkModePreference == "dark" ? .dark :
                settings.darkModePreference == "light" ? .light : nil
            )
            .onAppear {
                settings.resetVocabIfNewMonth()
                streak.checkResets()
            }
        }
    }
}
