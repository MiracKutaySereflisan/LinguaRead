import SwiftUI
import AVFoundation

/// Cihazda gelişmiş (enhanced/premium) ses yüklü değilse kullanıcıyı
/// iPhone ayarlarına yönlendiren bilgi kartı.
struct VoiceSetupBanner: View {
    private var hasEnhancedVoice: Bool {
        AVSpeechSynthesisVoice.speechVoices().contains {
            $0.quality == .enhanced || $0.quality == .premium
        }
    }

    var body: some View {
        if !hasEnhancedVoice {
            VStack(alignment: .leading, spacing: 8) {
                Label("Daha doğal ses için", systemImage: "speaker.wave.3.fill")
                    .font(.subheadline).bold()
                Text("iPhone Ayarlar → Erişilebilirlik → Seslendirilen İçerik → Sesler bölümünden Gelişmiş (Enhanced) ses indir. Uygulama otomatik kullanır.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Ayarları aç") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption).bold()
            }
            .padding(.vertical, 4)
        }
    }
}
