import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 連続学習記録
                    streakSection

                    // 全体統計
                    overallStatsSection

                    // 今週の正答率グラフ
                    weeklyChartSection

                    // 単語学習の進捗
                    vocabularyProgressSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("学習統計")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        HStack(spacing: 24) {
            statCard(
                icon: "flame.fill",
                color: .orange,
                value: "\(viewModel.streak.currentStreak)",
                unit: "日",
                label: "連続学習"
            )
            statCard(
                icon: "trophy.fill",
                color: .yellow,
                value: "\(viewModel.streak.longestStreak)",
                unit: "日",
                label: "最長記録"
            )
            statCard(
                icon: "calendar",
                color: .indigo,
                value: "\(viewModel.streak.totalDaysStudied)",
                unit: "日",
                label: "累計学習"
            )
        }
    }

    private func statCard(icon: String, color: Color, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Overall Stats

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("全体の成績")
                .font(.headline)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("累計回答数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalAnswered) 問")
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("全体正答率")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.accuracyText)
                        .font(.title3.bold())
                        .foregroundStyle(accuracyColor(viewModel.overallAccuracy))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Weekly Chart

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("今週の成績")
                    .font(.headline)
                Spacer()
                Text("正答率 \(viewModel.weeklyAccuracyText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.weeklyRecords.isEmpty {
                Text("今週のデータがまだありません")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                // 簡易バーチャート
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(viewModel.weeklyRecords) { record in
                        VStack(spacing: 4) {
                            if record.quizTotal > 0 {
                                Text(String(format: "%.0f%%", record.accuracy * 100))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }

                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColor(accuracy: record.accuracy))
                                .frame(
                                    width: 32,
                                    height: max(8, CGFloat(record.accuracy) * 100)
                                )

                            Text(dayLabel(record.date))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Vocabulary Progress

    private var vocabularyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("単語学習の進捗")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.vocabularyProgressText)
                        .font(.title2.bold())
                        .foregroundStyle(.teal)

                    Text("覚えた単語 / 全単語")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // 円形プログレス
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 64, height: 64)

                    Circle()
                        .trim(from: 0, to: vocabularyProgress)
                        .stroke(Color.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))

                    Text(String(format: "%.0f%%", vocabularyProgress * 100))
                        .font(.caption.bold())
                        .foregroundStyle(.teal)
                }
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Helpers

    private var vocabularyProgress: Double {
        guard viewModel.totalWords > 0 else { return 0 }
        return Double(viewModel.learnedWords) / Double(viewModel.totalWords)
    }

    private func accuracyColor(_ accuracy: Double) -> Color {
        switch accuracy {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }

    private func barColor(accuracy: Double) -> Color {
        switch accuracy {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        case 0.01..<0.6: return .red
        default: return Color(.systemGray5)
        }
    }

    private func dayLabel(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "ja_JP")
        dayFormatter.dateFormat = "E"
        return dayFormatter.string(from: date)
    }
}

#Preview {
    StatisticsView()
}
