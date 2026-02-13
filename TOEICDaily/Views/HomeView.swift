import SwiftUI

struct HomeView: View {
    @ObservedObject private var studyManager = StudyManager.shared
    @State private var showQuiz = false
    @State private var showVocabulary = false
    @State private var showReview = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ストリークカード
                    streakCard

                    // 今日の進捗
                    todayProgressCard

                    // メニューボタン
                    menuButtons
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("TOEIC Daily")
            .fullScreenCover(isPresented: $showQuiz) {
                QuizView(mode: .daily)
            }
            .fullScreenCover(isPresented: $showVocabulary) {
                VocabularyView()
            }
            .fullScreenCover(isPresented: $showReview) {
                QuizView(mode: .review)
            }
        }
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("連続学習")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(studyManager.streak.currentStreak)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.indigo)
                        Text("日")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("最長記録")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(studyManager.streak.longestStreak)日")
                        .font(.title3.bold())
                        .foregroundStyle(.indigo.opacity(0.7))
                }
            }

            // 曜日インジケーター
            weekIndicator
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var weekIndicator: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                VStack(spacing: 4) {
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Circle()
                        .fill(isStudied(day: day) ? Color.indigo : Color(.systemGray5))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if isStudied(day: day) {
                                Image(systemName: "checkmark")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                }
            }
        }
    }

    private var weekDays: [String] {
        ["月", "火", "水", "木", "金", "土", "日"]
    }

    private func isStudied(day: String) -> Bool {
        // 簡易実装: 今日の記録があれば今日の曜日にチェック
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        let today = formatter.string(from: Date())
        return day == today && studyManager.todayRecord.quizTotal > 0
    }

    // MARK: - Today Progress Card

    private var todayProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の学習")
                .font(.headline)

            HStack(spacing: 16) {
                progressItem(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    value: "\(studyManager.todayRecord.quizCorrect)/\(studyManager.todayRecord.quizTotal)",
                    label: "正解数"
                )

                progressItem(
                    icon: "book.fill",
                    color: .blue,
                    value: "\(studyManager.todayRecord.wordsReviewed)",
                    label: "学習単語"
                )

                progressItem(
                    icon: "percent",
                    color: .orange,
                    value: studyManager.todayRecord.quizTotal > 0
                        ? String(format: "%.0f%%", studyManager.todayRecord.accuracy * 100)
                        : "-",
                    label: "正答率"
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func progressItem(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Menu Buttons

    private var menuButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                menuButton(
                    title: "今日の5問",
                    subtitle: "Part 5 形式",
                    icon: "brain.head.profile",
                    color: .indigo
                ) {
                    showQuiz = true
                }

                menuButton(
                    title: "単語カード",
                    subtitle: "フリックで学習",
                    icon: "rectangle.stack.fill",
                    color: .teal
                ) {
                    showVocabulary = true
                }
            }

            HStack(spacing: 12) {
                menuButton(
                    title: "復習モード",
                    subtitle: "間違えた問題",
                    icon: "arrow.counterclockwise",
                    color: .orange
                ) {
                    showReview = true
                }

                menuButton(
                    title: "全問チャレンジ",
                    subtitle: "30問一気に",
                    icon: "flame.fill",
                    color: .red
                ) {
                    showQuiz = true
                }
            }
        }
    }

    private func menuButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
