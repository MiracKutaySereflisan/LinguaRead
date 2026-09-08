# LinguaRead

Yabancı dilde okuyarak kelime öğrenmek için iOS uygulaması. SwiftUI, iOS 17+.
Okuma, kelime çalışma ve quiz tek uygulamada birleşir.

## Ne yapıyor

- **Okuma.** Metindeki bir kelimeye basılı tut, anlamı yerinde açılır ve tek
  dokunuşla kelime defterine eklenir. Çeviri için MyMemory'nin ücretsiz API'si
  kullanılır.
- **Kütüphane.** Project Gutenberg ve Vikikaynak üzerinden kamu malı kitaplar
  indirilir. Kitaba dokununca önce özet sayfası açılır.
- **Kelime defteri.** Dil bazlı kayıt, kişisel notlar.
- **Quiz.** Kelime defterinden otomatik üretilir — eşleştirme ve boşluk doldurma.
- **İlerleme.** Seri (streak), haftalık hedef ve okuma istatistikleri.
- **Sesli okuma.** Cihaz üstü TTS, hız ayarı.
- **Arka plan sesi.** Okurken çalınabilen üç ortam sesi (piyano, yağmur, ambiyans).
- İlk okumada rehber katmanı, açılış ekranı, ücretsiz/premium kademeleri.

## Yapı

```
LinguaReadApp.swift     Giriş noktası
Managers/               Kütüphane kataloğu, indirme, saklama, quiz üretimi,
                        konuşma sentezi, seri takibi, arka plan sesi
Models/                 Kitap, kullanıcı profili, kelime kaydı, ayarlar
Views/                  Okuyucu, kütüphane, kelime, quiz, profil, ayarlar
Resources/SampleBooks/  Örnek metinler (bu proje için yazıldı)
Resources/Music/        Okuma sırasında çalınabilen arka plan sesleri
```

## Çalıştırma

```
Lingua Read.xcodeproj → aç → ⌘R
```

Xcode 16 veya üzeri, iOS 17.0+. Dış bağımlılık yok.

## Bu depoda olmayanlar

- **Promosyon kodları.** Ayarlardaki kod giriş alanı çalışır ama geçerli kod
  listesi (`AppSettings.validPromoCodes`) bu depoda boştur; kodlar yayına alınan
  yapıda tanımlanır.
- **StoreKit aboneliği.** Premium kademe arayüzü hazır, satın alma akışı bağlı
  değil.

## Telif

Uygulama kodunun ve örnek metinlerin tüm hakları saklıdır. Kütüphaneden
indirilen kitaplar Project Gutenberg ve Vikikaynak'tan gelir.
