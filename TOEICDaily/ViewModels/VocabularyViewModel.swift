import Foundation
import SwiftUI

class VocabularyViewModel: ObservableObject {
    @Published var words: [VocabularyWord] = []
    @Published var currentIndex: Int = 0
    @Published var showMeaning: Bool = false
    @Published var isFinished: Bool = false
    @Published var knownCount: Int = 0
    @Published var unknownCount: Int = 0
    @Published var offset: CGSize = .zero

    private let studyManager = StudyManager.shared

    var currentWord: VocabularyWord? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    var progress: Double {
        guard !words.isEmpty else { return 0 }
        return Double(currentIndex) / Double(words.count)
    }

    var remainingCount: Int {
        max(0, words.count - currentIndex)
    }

    func startSession(count: Int = 10) {
        words = studyManager.getVocabularyForReview(count: count)
        currentIndex = 0
        showMeaning = false
        isFinished = false
        knownCount = 0
        unknownCount = 0
        offset = .zero
    }

    func toggleMeaning() {
        showMeaning.toggle()
    }

    func markKnown() {
        guard let word = currentWord else { return }
        studyManager.markVocabularyKnown(wordId: word.id)
        knownCount += 1
        moveToNext()
    }

    func markUnknown() {
        guard let word = currentWord else { return }
        studyManager.markVocabularyUnknown(wordId: word.id)
        unknownCount += 1
        moveToNext()
    }

    func handleSwipe() {
        if offset.width > 100 {
            markKnown()
        } else if offset.width < -100 {
            markUnknown()
        }
        offset = .zero
    }

    private func moveToNext() {
        if currentIndex + 1 >= words.count {
            isFinished = true
        } else {
            currentIndex += 1
            showMeaning = false
        }
    }
}
