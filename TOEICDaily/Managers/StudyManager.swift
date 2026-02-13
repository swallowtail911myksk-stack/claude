import Foundation

class StudyManager: ObservableObject {
    static let shared = StudyManager()

    // MARK: - Published Properties
    @Published var streak: StudyStreak
    @Published var todayRecord: DailyStudyRecord
    @Published var vocabularyStatuses: [String: VocabularyStatus] // wordId -> status
    @Published var questionResults: [QuestionResult]

    // MARK: - Data
    private(set) var allQuestions: [Question] = []
    private(set) var allVocabulary: [VocabularyWord] = []

    // MARK: - UserDefaults Keys
    private let streakKey = "studyStreak"
    private let dailyRecordsKey = "dailyRecords"
    private let vocabStatusKey = "vocabularyStatuses"
    private let questionResultsKey = "questionResults"
    private let wrongQuestionIdsKey = "wrongQuestionIds"

    private init() {
        self.streak = StudyStreak()
        self.todayRecord = DailyStudyRecord()
        self.vocabularyStatuses = [:]
        self.questionResults = []
        loadData()
        loadSavedState()
    }

    // MARK: - Load bundled data

    private func loadData() {
        allQuestions = Self.loadJSON(filename: "questions") ?? []
        allVocabulary = Self.loadJSON(filename: "vocabulary") ?? []
    }

    private static func loadJSON<T: Decodable>(filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            // フォールバック: 開発中はファイルパスから読み込み
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error loading \(filename).json: \(error)")
            return nil
        }
    }

    // MARK: - Persistence

    private func loadSavedState() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: streakKey),
           let saved = try? JSONDecoder().decode(StudyStreak.self, from: data) {
            streak = saved
        }

        if let data = defaults.data(forKey: vocabStatusKey),
           let saved = try? JSONDecoder().decode([String: VocabularyStatus].self, from: data) {
            vocabularyStatuses = saved
        }

        if let data = defaults.data(forKey: questionResultsKey),
           let saved = try? JSONDecoder().decode([QuestionResult].self, from: data) {
            questionResults = saved
        }

        // 今日の記録を読み込み or 新規作成
        if let data = defaults.data(forKey: dailyRecordsKey),
           let records = try? JSONDecoder().decode([DailyStudyRecord].self, from: data),
           let today = records.first(where: { $0.date == DailyStudyRecord.todayId() }) {
            todayRecord = today
        } else {
            todayRecord = DailyStudyRecord()
        }
    }

    private func save() {
        let defaults = UserDefaults.standard

        if let data = try? JSONEncoder().encode(streak) {
            defaults.set(data, forKey: streakKey)
        }
        if let data = try? JSONEncoder().encode(vocabularyStatuses) {
            defaults.set(data, forKey: vocabStatusKey)
        }
        if let data = try? JSONEncoder().encode(questionResults) {
            defaults.set(data, forKey: questionResultsKey)
        }

        // 日次記録を保存
        saveDailyRecord()
    }

    private func saveDailyRecord() {
        let defaults = UserDefaults.standard
        var records: [DailyStudyRecord] = []

        if let data = defaults.data(forKey: dailyRecordsKey),
           let saved = try? JSONDecoder().decode([DailyStudyRecord].self, from: data) {
            records = saved.filter { $0.date != todayRecord.date }
        }

        records.append(todayRecord)

        // 直近90日分だけ保持
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let cutoff = formatter.string(from: cutoffDate)
        records = records.filter { $0.date >= cutoff }

        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: dailyRecordsKey)
        }
    }

    // MARK: - Quiz Functions

    func getDailyQuestions(count: Int = 5) -> [Question] {
        guard !allQuestions.isEmpty else { return [] }
        var shuffled = allQuestions.shuffled()
        return Array(shuffled.prefix(count))
    }

    func getWrongQuestions() -> [Question] {
        let wrongIds = Set(
            questionResults
                .filter { !$0.isCorrect }
                .map { $0.questionId }
        )
        let correctIds = Set(
            questionResults
                .filter { $0.isCorrect }
                .map { $0.questionId }
        )
        // まだ正解していない問題を返す
        let needReview = wrongIds.subtracting(correctIds)
        return allQuestions.filter { needReview.contains($0.id) }.shuffled()
    }

    func recordQuizResult(questionId: String, selectedIndex: Int, isCorrect: Bool) {
        let result = QuestionResult(
            questionId: questionId,
            selectedIndex: selectedIndex,
            isCorrect: isCorrect
        )
        questionResults.append(result)

        todayRecord.quizTotal += 1
        if isCorrect {
            todayRecord.quizCorrect += 1
        }

        streak.recordStudy()
        save()
    }

    // MARK: - Vocabulary Functions

    func getVocabularyForReview(count: Int = 10) -> [VocabularyWord] {
        let now = Date()
        // 復習が必要な単語を優先
        let needReview = allVocabulary.filter { word in
            guard let status = vocabularyStatuses[word.id] else { return true }
            return status.nextReviewAt <= now
        }

        if needReview.count >= count {
            return Array(needReview.shuffled().prefix(count))
        }

        // 足りない場合は残りからランダムに追加
        let remaining = allVocabulary.filter { word in
            !needReview.contains(where: { $0.id == word.id })
        }
        return (needReview + remaining.shuffled()).prefix(count).shuffled()
    }

    func markVocabularyKnown(wordId: String) {
        var status = vocabularyStatuses[wordId] ?? VocabularyStatus(wordId: wordId)
        status.markKnown()
        vocabularyStatuses[wordId] = status

        todayRecord.wordsReviewed += 1
        if status.isLearned {
            todayRecord.wordsLearned += 1
        }

        streak.recordStudy()
        save()
    }

    func markVocabularyUnknown(wordId: String) {
        var status = vocabularyStatuses[wordId] ?? VocabularyStatus(wordId: wordId)
        status.markUnknown()
        vocabularyStatuses[wordId] = status

        todayRecord.wordsReviewed += 1

        streak.recordStudy()
        save()
    }

    // MARK: - Statistics

    func getWeeklyRecords() -> [DailyStudyRecord] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: dailyRecordsKey),
              let records = try? JSONDecoder().decode([DailyStudyRecord].self, from: data) else {
            return [todayRecord]
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let cutoff = formatter.string(from: weekAgo)

        var weekRecords = records.filter { $0.date > cutoff }
        if !weekRecords.contains(where: { $0.date == todayRecord.date }) {
            weekRecords.append(todayRecord)
        }
        return weekRecords.sorted { $0.date < $1.date }
    }

    var totalQuestionsAnswered: Int {
        questionResults.count
    }

    var overallAccuracy: Double {
        guard !questionResults.isEmpty else { return 0 }
        let correct = questionResults.filter { $0.isCorrect }.count
        return Double(correct) / Double(questionResults.count)
    }

    var learnedWordsCount: Int {
        vocabularyStatuses.values.filter { $0.isLearned }.count
    }

    var totalWordsCount: Int {
        allVocabulary.count
    }
}
