import SwiftUI

struct ReviewView: View {
    @StateObject private var viewModel = ReviewViewModel()

    var body: some View {
        VStack {
            if viewModel.hasWrongQuestions {
                QuizView(mode: .review)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    Text("間違えた問題はありません")
                        .font(.title3)
                    Text("クイズで間違えた問題が\nここに自動で追加されます")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

#Preview {
    ReviewView()
}
