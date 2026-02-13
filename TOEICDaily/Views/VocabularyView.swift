import SwiftUI

struct VocabularyView: View {
    @StateObject private var viewModel = VocabularyViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isFinished {
                    finishedView
                } else if let word = viewModel.currentWord {
                    VStack(spacing: 20) {
                        // プログレス
                        ProgressView(value: viewModel.progress)
                            .tint(.teal)
                            .padding(.horizontal)

                        HStack {
                            Text("残り \(viewModel.remainingCount) 語")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        Spacer()

                        // カード
                        flashcard(word)

                        Spacer()

                        // 操作ボタン
                        if viewModel.showMeaning {
                            actionButtons
                        } else {
                            Button(action: { viewModel.toggleMeaning() }) {
                                Text("タップして意味を見る")
                                    .font(.headline)
                                    .foregroundStyle(.teal)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.teal.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                        }

                        // スワイプヒント
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("まだ")
                            Spacer()
                            Text("覚えた")
                            Image(systemName: "arrow.right")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 40)
                        .padding(.bottom)
                    }
                } else {
                    Text("単語データを読み込み中...")
                }
            }
            .navigationTitle("単語カード")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.startSession()
        }
    }

    // MARK: - Flashcard

    private func flashcard(_ word: VocabularyWord) -> some View {
        VStack(spacing: 16) {
            // レベルタグ
            HStack {
                Text(word.level.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(.teal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.1))
                    .clipShape(Capsule())

                Text(word.partOfSpeech)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            // 英単語
            Text(word.english)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            if viewModel.showMeaning {
                Divider()

                // 日本語訳
                Text(word.japanese)
                    .font(.title2)
                    .foregroundStyle(.indigo)

                // 例文
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.exampleSentence)
                        .font(.subheadline)
                        .italic()
                    Text(word.exampleTranslation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal)
        .offset(x: viewModel.offset.width)
        .rotationEffect(.degrees(Double(viewModel.offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    viewModel.offset = gesture.translation
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        viewModel.handleSwipe()
                    }
                }
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.toggleMeaning()
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.markUnknown()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                    Text("まだ")
                        .font(.caption.bold())
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: {
                withAnimation(.spring()) {
                    viewModel.markKnown()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                    Text("覚えた")
                        .font(.caption.bold())
                }
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 60))
                .foregroundStyle(.teal)

            Text("お疲れさまでした！")
                .font(.title.bold())

            HStack(spacing: 32) {
                VStack {
                    Text("\(viewModel.knownCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    Text("覚えた")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack {
                    Text("\(viewModel.unknownCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                    Text("まだ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 12) {
                Button(action: { viewModel.startSession() }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("もう一度")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: { dismiss() }) {
                    Text("ホームに戻る")
                        .font(.headline)
                        .foregroundStyle(.teal)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    VocabularyView()
}
