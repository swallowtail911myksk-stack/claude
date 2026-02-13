import Foundation

class ReviewViewModel: ObservableObject {
    @Published var wrongQuestions: [Question] = []
    @Published var hasWrongQuestions: Bool = false

    private let studyManager = StudyManager.shared

    func refresh() {
        wrongQuestions = studyManager.getWrongQuestions()
        hasWrongQuestions = !wrongQuestions.isEmpty
    }

    var wrongCount: Int {
        wrongQuestions.count
    }
}
