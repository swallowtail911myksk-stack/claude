import SwiftUI

struct QuizResultView: View {
    let correctCount: Int
    let totalCount: Int
    let onDismiss: () -> Void
    let onRetry: () -> Void

    private var accuracy: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount)
    }

    private var grade: Grade {
        switch accuracy {
        case 0.9...1.0: return .excellent
        case 0.7..<0.9: return .good
        case 0.5..<0.7: return .okay
        default: return .needsWork
        }
    }

    enum Grade {
        case excellent, good, okay, needsWork

        var emoji: String {
            switch self {
            case .excellent: return "star.fill"
            case .good: return "hand.thumbsup.fill"
            case .okay: return "face.smiling"
            case .needsWork: return "book.fill"
            }
        }

        var message: String {
            switch self {
            case .excellent: return "素晴らしい！"
            case .good: return "よくできました！"
            case .okay: return "もう少し！"
            case .needsWork: return "復習しましょう！"
            }
        }

        var color: Color {
            switch self {
            case .excellent: return .yellow
            case .good: return .green
            case .okay: return .orange
            case .needsWork: return .indigo
            }
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // アイコン
            Image(systemName: grade.emoji)
                .font(.system(size: 72))
                .foregroundStyle(grade.color)

            // メッセージ
            Text(grade.message)
                .font(.largeTitle.bold())

            // スコア
            VStack(spacing: 8) {
                Text("\(correctCount) / \(totalCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.indigo)

                Text(String(format: "正答率 %.0f%%", accuracy * 100))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // スコアバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(grade.color)
                        .frame(width: geometry.size.width * accuracy, height: 16)
                }
            }
            .frame(height: 16)
            .padding(.horizontal, 40)

            Spacer()

            // ボタン
            VStack(spacing: 12) {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("もう一度挑戦")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onDismiss) {
                    Text("ホームに戻る")
                        .font(.headline)
                        .foregroundStyle(.indigo)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    QuizResultView(
        correctCount: 4,
        totalCount: 5,
        onDismiss: {},
        onRetry: {}
    )
}
