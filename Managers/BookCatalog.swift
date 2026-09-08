// Copyright (c) 2026 Mirac Kutay Sereflisan. Tum haklari saklidir.
import Foundation

struct CatalogEntry: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let language: BookLanguage
    let level: CEFRLevel
    let category: String
    var gutenbergID: Int? = nil
    var wikisourceTitle: String? = nil
    var summary: String = ""
    var estimatedMinutes: Int = 60
    var wordCount: Int = 10000

    var isWikisource: Bool { wikisourceTitle != nil }

    var textURL: URL? {
        if let g = gutenbergID {
            return URL(string: "https://www.gutenberg.org/files/\(g)/\(g)-0.txt")
        }
        if let w = wikisourceTitle,
           let enc = w.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "https://tr.wikisource.org/w/api.php?action=query&prop=extracts&explaintext=1&format=json&titles=\(enc)")
        }
        return nil
    }

    var coverURL: URL? {
        guard let g = gutenbergID else { return nil }
        return URL(string: "https://www.gutenberg.org/cache/epub/\(g)/pg\(g).cover.medium.jpg")
    }
}

enum BookCatalog {
    static let entries: [CatalogEntry] = [
        // ── İNGİLİZCE ──
        CatalogEntry(id: "en-alice", title: "Alice's Adventures in Wonderland", author: "Lewis Carroll",
            language: .english, level: .a2, category: "Fantastik", gutenbergID: 11,
            summary: "Alice, beyaz bir tavşanın peşinden tuhaf bir diyara düşer. Konuşan hayvanlar, çılgın çay partileri ve mantığın tersyüz olduğu bir dünya. Kısa cümleleriyle başlangıç seviyesi için ideal bir klasik.",
            estimatedMinutes: 150, wordCount: 26000),
        CatalogEntry(id: "en-oz", title: "The Wonderful Wizard of Oz", author: "L. Frank Baum",
            language: .english, level: .a2, category: "Fantastik", gutenbergID: 55,
            summary: "Dorothy bir kasırgayla Oz diyarına savrulur. Eve dönmek için Korkuluk, Teneke Adam ve Korkak Aslan'la birlikte Büyücü'yü aramaya çıkar. Basit ve akıcı bir dille yazılmış sevimli bir macera.",
            estimatedMinutes: 160, wordCount: 39000),
        CatalogEntry(id: "en-sherlock", title: "The Adventures of Sherlock Holmes", author: "Arthur Conan Doyle",
            language: .english, level: .b1, category: "Polisiye", gutenbergID: 1661,
            summary: "Holmes ve Watson'ın en ünlü on iki vakası. Her öykü bağımsız okunabilir; kısa bölümler halinde ilerlemek isteyenler için mükemmel. Victoria dönemi Londra'sında zekâ dolu çözümler.",
            estimatedMinutes: 420, wordCount: 105000),
        CatalogEntry(id: "en-tomsawyer", title: "The Adventures of Tom Sawyer", author: "Mark Twain",
            language: .english, level: .b1, category: "Macera", gutenbergID: 74,
            summary: "Yaramaz Tom, Mississippi kıyısındaki kasabasında maceradan maceraya koşar. Çit boyama oyunundan mağara kaçışına, Amerikan edebiyatının en eğlenceli çocukluk hikâyesi.",
            estimatedMinutes: 300, wordCount: 71000),
        CatalogEntry(id: "en-gatsby", title: "The Great Gatsby", author: "F. Scott Fitzgerald",
            language: .english, level: .b2, category: "Roman", gutenbergID: 64317,
            summary: "Caz Çağı'nın parıltılı partileri ardında saklanan imkânsız bir aşk. Gatsby'nin yeşil ışığa uzanan hikâyesi, Amerikan Rüyası'nın en zarif eleştirisi. Orta-üstü seviye için zengin kelime hazinesi.",
            estimatedMinutes: 200, wordCount: 47000),
        CatalogEntry(id: "en-prideprej", title: "Pride and Prejudice", author: "Jane Austen",
            language: .english, level: .c1, category: "Klasik", gutenbergID: 1342,
            summary: "Elizabeth Bennet ile Mr. Darcy arasında önyargılarla örülü, zekâ dolu bir aşk hikâyesi. İnce ironisi ve dönem İngilizcesiyle ileri seviye okurlar için gerçek bir sınav ve ödül.",
            estimatedMinutes: 480, wordCount: 122000),
        CatalogEntry(id: "en-dorian", title: "The Picture of Dorian Gray", author: "Oscar Wilde",
            language: .english, level: .c1, category: "Klasik", gutenbergID: 174,
            summary: "Genç ve güzel Dorian'ın portresi onun yerine yaşlanır; ruhundaki karanlık tabloya işler. Wilde'ın keskin aforizmalarıyla dolu, estetik ve ahlak üzerine büyüleyici bir roman.",
            estimatedMinutes: 320, wordCount: 78000),

        // ── ALMANCA ──
        CatalogEntry(id: "de-verwandlung", title: "Die Verwandlung", author: "Franz Kafka",
            language: .german, level: .b1, category: "Klasik", gutenbergID: 22367,
            summary: "Gregor Samsa bir sabah dev bir böceğe dönüşmüş olarak uyanır. Kafka'nın en ünlü eseri; kısa oluşu ve tekrar eden kelime yapısıyla Almanca öğrenenler için şaşırtıcı derecede erişilebilir.",
            estimatedMinutes: 120, wordCount: 22000),
        CatalogEntry(id: "de-grimm", title: "Grimms Märchen", author: "Brüder Grimm",
            language: .german, level: .a2, category: "Masal", gutenbergID: 52521,
            summary: "Pamuk Prenses'ten Kırmızı Başlıklı Kız'a Grimm kardeşlerin klasik masalları. Kısa öyküler, basit cümle yapıları ve bilinen hikâyeler — Almanca'ya başlamanın en keyifli yolu.",
            estimatedMinutes: 240, wordCount: 60000),
        CatalogEntry(id: "de-siddhartha", title: "Siddhartha", author: "Hermann Hesse",
            language: .german, level: .b2, category: "Felsefe", gutenbergID: 2500,
            summary: "Genç Siddhartha aydınlanmayı aramak için evini terk eder. Hesse'nin şiirsel ve ritmik Almancası, nehir gibi akan bir anlatım. Orta-üstü seviye için ruhu besleyen bir yolculuk.",
            estimatedMinutes: 180, wordCount: 41000),
        CatalogEntry(id: "de-werther", title: "Die Leiden des jungen Werther", author: "J. W. von Goethe",
            language: .german, level: .c1, category: "Klasik", gutenbergID: 2407,
            summary: "Genç Werther'in imkânsız aşkını mektuplar halinde anlatan, Avrupa'yı sarsan roman. Goethe'nin duygusal ve yoğun dili ileri seviye okurlar için etkileyici bir deneyim.",
            estimatedMinutes: 200, wordCount: 45000),

        // ── TÜRKÇE (Wikisource — Ömer Seyfettin) ──
        CatalogEntry(id: "tr-kasagi", title: "Kaşağı", author: "Ömer Seyfettin",
            language: .turkish, level: .a2, category: "Öykü", wikisourceTitle: "Kaşağı",
            summary: "Bir çocuğun kıskançlıkla söylediği yalanın ağır bedeli. Türk edebiyatının en dokunaklı kısa öykülerinden biri; sade dili ile yeni okurlar için ideal.",
            estimatedMinutes: 15, wordCount: 2500),
        CatalogEntry(id: "tr-pembe", title: "Pembe İncili Kaftan", author: "Ömer Seyfettin",
            language: .turkish, level: .b1, category: "Öykü", wikisourceTitle: "Pembe İncili Kaftan",
            summary: "Onuruna düşkün Muhsin Çelebi, Şah İsmail'in huzurunda devletin gururunu kaftanıyla korur. Tarihî atmosferi ve güçlü karakteriyle unutulmaz bir öykü.",
            estimatedMinutes: 25, wordCount: 4200),
        CatalogEntry(id: "tr-diyet", title: "Diyet", author: "Ömer Seyfettin",
            language: .turkish, level: .b1, category: "Öykü", wikisourceTitle: "Diyet",
            summary: "Koca Ali'nin minnet borcu üzerine kurulu, gurur ve özgürlük temalı sarsıcı bir öykü. Kısa ama derin; kelime dağarcığını genişletmek isteyenlere birebir.",
            estimatedMinutes: 20, wordCount: 3500),
        CatalogEntry(id: "tr-topuz", title: "Topuz", author: "Ömer Seyfettin",
            language: .turkish, level: .b2, category: "Öykü", wikisourceTitle: "Topuz",
            summary: "Bir elçilik heyetinde geçen, diplomasi ve cesaret üzerine ironik bir hikâye. Seyfettin'in keskin mizahını gösteren, akıcı bir okuma.",
            estimatedMinutes: 20, wordCount: 3200),
    ]

    static func entries(for language: BookLanguage) -> [CatalogEntry] {
        entries.filter { $0.language == language }.sorted { $0.level < $1.level }
    }
}
