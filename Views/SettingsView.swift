// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(MusicPlayer.self) private var music

    @State private var promoInput = ""
    @State private var promoMessage: String?

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            Form {
                Section("Okuma") {
                    VStack(alignment: .leading) {
                        Text("Varsayılan okuma hızı: \(String(format: "%.2f", settings.speechRate))")
                            .font(.caption).foregroundStyle(.secondary)
                        Slider(value: $settings.speechRate, in: 0.25...0.70)
                    }
                    VoiceSetupBanner()
                }

                Section("Müzik") {
                    VStack(alignment: .leading) {
                        Text("Arka plan müziği sesi")
                            .font(.caption).foregroundStyle(.secondary)
                        Slider(value: Binding(
                            get: { Double(settings.backgroundMusicVolume) },
                            set: {
                                settings.backgroundMusicVolume = Float($0)
                                music.setVolume(Float($0))
                            }
                        ), in: 0...1)
                    }
                }

                Section("Görünüm") {
                    Picker("Tema", selection: $settings.darkModePreference) {
                        Text("Sistem").tag("system")
                        Text("Açık").tag("light")
                        Text("Koyu").tag("dark")
                    }
                }

                Section("Premium") {
                    if settings.isPremium {
                        Label("Premium aktif", systemImage: "crown.fill")
                            .foregroundStyle(.orange)
                    } else {
                        TextField("Promosyon kodu", text: $promoInput)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()

                        Button("Kodu kullan") {
                            if settings.redeemPromoCode(promoInput) {
                                promoMessage = "Premium açıldı! 🎉"
                                promoInput = ""
                            } else {
                                promoMessage = "Geçersiz kod"
                            }
                        }

                        if let msg = promoMessage {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(msg.contains("🎉") ? .green : .red)
                        }
                    }
                }

                Section("Hakkında") {
                    LabeledContent("Sürüm", value: "1.0")
                }
            }
            .navigationTitle("Ayarlar")
        }
    }
}
