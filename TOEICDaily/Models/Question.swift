import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let sentence: String        // 問題文（___で空欄を表す）
    let choices: [String]       // 4つの選択肢
    let correctIndex: Int       // 正解のインデックス (0-3)
    let explanation: String     // 解説
    let category: QuestionCategory
    let difficulty: Difficulty

    enum QuestionCategory: String, Codable, CaseIterable {
        case grammar = "文法"
        case vocabulary = "語彙"
        case partOfSpeech = "品詞"
        case preposition = "前置詞"
        case conjunction = "接続詞"
        case tense = "時制"
    }

    enum Difficulty: String, Codable, CaseIterable {
        case beginner = "初級"      // 400点レベル
        case intermediate = "中級"  // 600点レベル
        case advanced = "上級"      // 800点レベル
    }
}

struct QuestionResult: Codable, Identifiable {
    let id: String
    let questionId: String
    let selectedIndex: Int
    let isCorrect: Bool
    let answeredAt: Date

    init(questionId: String, selectedIndex: Int, isCorrect: Bool) {
        self.id = UUID().uuidString
        self.questionId = questionId
        self.selectedIndex = selectedIndex
        self.isCorrect = isCorrect
        self.answeredAt = Date()
    }
}
