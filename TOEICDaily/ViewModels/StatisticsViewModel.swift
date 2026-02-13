import Foundation

class StatisticsViewModel: ObservableObject {
    @Published var weeklyRecords: [DailyStudyRecord] = []
    @Published var streak: StudyStreak = StudyStreak()
    @Published var overallAccuracy: Double = 0
    @Published var totalAnswered: Int = 0
    @Published var learnedWords: Int = 0
    @Published var totalWords: Int = 0

    private let studyManager = StudyManager.shared

    func refresh() {
        weeklyRecords = studyManager.getWeeklyRecords()
        streak = studyManager.streak
        overallAccuracy = studyManager.overallAccuracy
        totalAnswered = studyManager.totalQuestionsAnswered
        learnedWords = studyManager.learnedWordsCount
        totalWords = studyManager.totalWordsCount
    }

    var weeklyAccuracy: Double {
        let total = weeklyRecords.reduce(0) { $0 + $1.quizTotal }
        let correct = weeklyRecords.reduce(0) { $0 + $1.quizCorrect }
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }

    var weeklyQuestionsCount: Int {
        weeklyRecords.reduce(0) { $0 + $1.quizTotal }
    }

    var accuracyText: String {
        String(format: "%.0f%%", overallAccuracy * 100)
    }

    var weeklyAccuracyText: String {
        String(format: "%.0f%%", weeklyAccuracy * 100)
    }

    var vocabularyProgressText: String {
        "\(learnedWords) / \(totalWords)"
    }
}
