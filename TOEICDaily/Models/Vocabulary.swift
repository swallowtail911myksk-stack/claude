import Foundation

struct VocabularyWord: Codable, Identifiable {
    let id: String
    let english: String         // 英単語
    let japanese: String        // 日本語訳
    let partOfSpeech: String    // 品詞
    let exampleSentence: String // 例文
    let exampleTranslation: String // 例文の和訳
    let level: Level

    enum Level: String, Codable, CaseIterable {
        case basic = "基礎"        // 400点レベル
        case essential = "必須"    // 600点レベル
        case advanced = "発展"     // 800点レベル
    }
}

struct VocabularyStatus: Codable {
    let wordId: String
    var knownCount: Int        // 「知ってる」を押した回数
    var unknownCount: Int      // 「まだ」を押した回数
    var lastReviewedAt: Date
    var nextReviewAt: Date     // 間隔反復法による次回復習日

    var isLearned: Bool {
        knownCount >= 3 && knownCount > unknownCount * 2
    }

    init(wordId: String) {
        self.wordId = wordId
        self.knownCount = 0
        self.unknownCount = 0
        self.lastReviewedAt = Date()
        self.nextReviewAt = Date()
    }

    mutating func markKnown() {
        knownCount += 1
        lastReviewedAt = Date()
        // 間隔反復: 知ってるを押すほど次の復習まで長くなる
        let days = min(pow(2.0, Double(knownCount)), 30.0)
        nextReviewAt = Calendar.current.date(byAdding: .day, value: Int(days), to: Date()) ?? Date()
    }

    mutating func markUnknown() {
        unknownCount += 1
        lastReviewedAt = Date()
        // 間違えたらすぐ復習
        nextReviewAt = Date()
    }
}
