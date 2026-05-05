import SwiftUI

struct LearningCardsView: View {
    let topic: Topic
    @StateObject private var viewModel: LearningCardsViewModel
    @State private var dragOffset: CGSize = .zero

    init(topic: Topic) {
        self.topic = topic
        _viewModel = StateObject(wrappedValue: LearningCardsViewModel(topic: topic))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.cards) { card in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(card.prompt)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)

                        if viewModel.revealedCardID == card.id {
                            Text(card.explanation)
                                .foregroundStyle(Color.appTextSecondary)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Text("Swipe left or right, then tap to reveal explanation.")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .appCardStyle()
                    .offset(x: dragOffset.width)
                    .gesture(
                        DragGesture()
                            .onChanged { dragOffset = $0.translation }
                            .onEnded { _ in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    dragOffset = .zero
                                }
                            }
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.toggle(cardID: card.id)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.revealedCardID)
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Learning Cards")
        .toolbarTitleDisplayMode(.inline)
    }
}
