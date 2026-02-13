import SwiftUI

struct QuizView: View {
    enum Mode {
        case daily
        case review
    }

    let mode: Mode
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isFinished {
                    QuizResultView(
                        correctCount: viewModel.correctCount,
                        totalCount: viewModel.totalCount,
                        onDismiss: { dismiss() },
                        onRetry: {
                            switch mode {
                            case .daily: viewModel.startDailyQuiz()
                            case .review: viewModel.startReviewQuiz()
                            }
                        }
                    )
                } else if let question = viewModel.currentQuestion {
                    questionContent(question)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                        Text("復習する問題がありません")
                            .font(.title3)
                        Text("問題を解いて間違えると\nここに復習問題が追加されます")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationTitle(mode == .daily ? "今日の5問" : "復習モード")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.questions.isEmpty {
                        Text("\(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            switch mode {
            case .daily: viewModel.startDailyQuiz()
            case .review: viewModel.startReviewQuiz()
            }
        }
    }

    // MARK: - Question Content

    private func questionContent(_ question: Question) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // プログレスバー
                ProgressView(value: viewModel.progress)
                    .tint(.indigo)
                    .padding(.horizontal)

                // カテゴリ & 難易度タグ
                HStack {
                    tag(question.category.rawValue, color: .indigo)
                    tag(question.difficulty.rawValue, color: difficultyColor(question.difficulty))
                    Spacer()
                }
                .padding(.horizontal)

                // 問題文
                VStack(alignment: .leading, spacing: 12) {
                    Text("次の空欄に入る最も適切な語を選んでください。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(question.sentence)
                        .font(.body)
                        .lineSpacing(6)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // 選択肢
                VStack(spacing: 10) {
                    ForEach(0..<question.choices.count, id: \.self) { index in
                        choiceButton(index: index, text: question.choices[index])
                    }
                }
                .padding(.horizontal)

                // 解説
                if viewModel.showExplanation {
                    explanationCard(question)

                    Button(action: { viewModel.nextQuestion() }) {
                        Text(viewModel.currentIndex + 1 >= viewModel.questions.count ? "結果を見る" : "次の問題へ")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
    }

    private func choiceButton(index: Int, text: String) -> some View {
        Button(action: { viewModel.selectAnswer(index) }) {
            HStack {
                Text(choiceLetter(index))
                    .font(.headline)
                    .foregroundStyle(viewModel.answerColor(for: index))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .stroke(viewModel.answerColor(for: index), lineWidth: 2)
                    )

                Text(text)
                    .font(.body)
                    .foregroundStyle(viewModel.answerColor(for: index))

                Spacer()

                if let selected = viewModel.selectedAnswer {
                    if let question = viewModel.currentQuestion {
                        if index == question.correctIndex {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else if index == selected {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .padding()
            .background(viewModel.answerBackground(for: index))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.selectedAnswer != nil && index == viewModel.currentQuestion?.correctIndex
                            ? Color.green
                            : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(viewModel.selectedAnswer != nil)
        .buttonStyle(.plain)
    }

    private func explanationCard(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("解説")
                    .font(.headline)
            }

            Text(question.explanation)
                .font(.subheadline)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func tag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }

    private func choiceLetter(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }

    private func difficultyColor(_ difficulty: Question.Difficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

#Preview {
    QuizView(mode: .daily)
}
