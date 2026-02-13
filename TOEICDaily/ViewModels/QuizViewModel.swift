import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showExplanation: Bool = false
    @Published var results: [QuestionResult] = []
    @Published var isFinished: Bool = false

    private let studyManager = StudyManager.shared

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var correctCount: Int {
        results.filter { $0.isCorrect }.count
    }

    var totalCount: Int {
        results.count
    }

    func startDailyQuiz() {
        questions = studyManager.getDailyQuestions()
        currentIndex = 0
        selectedAnswer = nil
        showExplanation = false
        results = []
        isFinished = false
    }

    func startReviewQuiz() {
        questions = studyManager.getWrongQuestions()
        if questions.isEmpty {
            questions = studyManager.getDailyQuestions()
        }
        currentIndex = 0
        selectedAnswer = nil
        showExplanation = false
        results = []
        isFinished = false
    }

    func selectAnswer(_ index: Int) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }

        selectedAnswer = index
        showExplanation = true

        let isCorrect = index == question.correctIndex
        studyManager.recordQuizResult(
            questionId: question.id,
            selectedIndex: index,
            isCorrect: isCorrect
        )

        let result = QuestionResult(
            questionId: question.id,
            selectedIndex: index,
            isCorrect: isCorrect
        )
        results.append(result)
    }

    func nextQuestion() {
        if currentIndex + 1 >= questions.count {
            isFinished = true
        } else {
            currentIndex += 1
            selectedAnswer = nil
            showExplanation = false
        }
    }

    func answerColor(for index: Int) -> Color {
        guard let selected = selectedAnswer, let question = currentQuestion else {
            return .primary
        }

        if index == question.correctIndex {
            return .green
        } else if index == selected {
            return .red
        }
        return .primary
    }

    func answerBackground(for index: Int) -> Color {
        guard let selected = selectedAnswer, let question = currentQuestion else {
            return Color(.systemGray6)
        }

        if index == question.correctIndex {
            return Color.green.opacity(0.15)
        } else if index == selected {
            return Color.red.opacity(0.15)
        }
        return Color(.systemGray6)
    }
}
