import Foundation

struct DailyStudyRecord: Codable, Identifiable {
    let id: String
    let date: String            // "yyyy-MM-dd" 形式
    var quizCorrect: Int        // クイズ正解数
    var quizTotal: Int          // クイズ出題数
    var wordsReviewed: Int      // 復習した単語数
    var wordsLearned: Int       // 新たに覚えた単語数
    var studyDurationSeconds: Int // 学習時間（秒）

    var accuracy: Double {
        guard quizTotal > 0 else { return 0 }
        return Double(quizCorrect) / Double(quizTotal)
    }

    static func todayId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    init(date: String = todayId()) {
        self.id = date
        self.date = date
        self.quizCorrect = 0
        self.quizTotal = 0
        self.wordsReviewed = 0
        self.wordsLearned = 0
        self.studyDurationSeconds = 0
    }
}

struct StudyStreak: Codable {
    var currentStreak: Int      // 現在の連続日数
    var longestStreak: Int      // 最長連続日数
    var lastStudyDate: String   // 最後に学習した日 "yyyy-MM-dd"
    var totalDaysStudied: Int   // 累計学習日数

    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastStudyDate = ""
        self.totalDaysStudied = 0
    }

    mutating func recordStudy() {
        let today = DailyStudyRecord.todayId()

        if lastStudyDate == today {
            return // 今日はすでに記録済み
        }

        let yesterday = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
                return formatter.string(from: date)
            }
            return ""
        }()

        if lastStudyDate == yesterday {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastStudyDate = today
        totalDaysStudied += 1
    }
}
