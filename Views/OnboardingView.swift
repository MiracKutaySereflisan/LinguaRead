import SwiftUI

struct OnboardingView: View {
    @Environment(UserProfile.self) private var profile

    @State private var name = ""
    @State private var language: BookLanguage = .english
    @State private var level: CEFRLevel = .a2

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 48)).foregroundStyle(.blue)
                Text("LinguaRead'e hoş geldin")
                    .font(.title2).bold()
                Text("Okuyarak dil öğren")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 18) {
                TextField("Adın (isteğe bağlı)", text: $name)
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hangi dili öğreniyorsun?").font(.subheadline).bold()
                    Picker("Dil", selection: $language) {
                        ForEach(BookLanguage.allCases, id: \.self) {
                            Text("\($0.flag) \($0.displayName)").tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Seviyen nedir?").font(.subheadline).bold()
                    Picker("Seviye", selection: $level) {
                        ForEach(CEFRLevel.allCases, id: \.self) {
                            Text($0.label).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(.horizontal, 24)

            Button {
                profile.name = name
                profile.selectedLanguage = language
                profile.selectedLevel = level
                profile.hasOnboarded = true
            } label: {
                Text("Başla")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
