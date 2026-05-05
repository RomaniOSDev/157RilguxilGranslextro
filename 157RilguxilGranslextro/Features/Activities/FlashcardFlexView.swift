import SwiftUI

struct FlashcardFlexView: View {
    @EnvironmentObject private var store: LearningDataStore
    let topic: Topic
    @State private var difficulty: ActivityDifficulty = .easy
    @State private var started = false
    @StateObject private var viewModel: FlashcardFlexViewModel
    @State private var isFlipped = false
    @State private var showResult = false
    @State private var swipeHintPulse = false
    @State private var summary: ActivitySessionSummary?
    @State private var startedAt = Date()

    init(topic: Topic) {
        self.topic = topic
        _viewModel = StateObject(wrappedValue: FlashcardFlexViewModel(topic: topic, difficulty: .easy))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    if !started {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Difficulty")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)

                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(ActivityDifficulty.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .appCardStyle()

                        Button("Start Flashcard Drill") {
                            viewModel.configure(topic: topic, difficulty: difficulty)
                            started = true
                            isFlipped = false
                            startedAt = Date()
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                    } else if let card = viewModel.currentCard {
                        FlashcardHeaderCard(
                            current: viewModel.currentIndex + 1,
                            total: max(1, viewModel.cards.count),
                            timeLeft: viewModel.remainingTime,
                            maxTime: viewModel.difficulty.timeLimit
                        )

                        VStack(spacing: 12) {
                            Text(isFlipped ? card.explanation : card.prompt)
                                .foregroundStyle(Color.appTextPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(6)
                                .minimumScaleFactor(0.7)
                                .font(.title3.weight(.semibold))

                            Text(isFlipped ? "Tap again to see prompt" : "Tap to reveal explanation")
                                .foregroundStyle(Color.appTextSecondary)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .appCardStyle()
                        .overlay(alignment: .bottom) {
                            HStack(spacing: 18) {
                                Label("Understood", systemImage: "arrow.left.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                                Label("Review Later", systemImage: "arrow.right.circle.fill")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.bottom, 12)
                            .opacity(swipeHintPulse ? 1 : 0.55)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: swipeHintPulse)
                        }
                        .modifier(SwipeActionModifier(
                            onSwipeLeft: { viewModel.handleSwipe(left: true); isFlipped = false },
                            onSwipeRight: { viewModel.handleSwipe(left: false); isFlipped = false }
                        ))
                        .scaleEffect(isFlipped ? 1.03 : 1)
                        .animation(.easeInOut(duration: 0.3), value: isFlipped)
                        .onTapGesture { isFlipped.toggle() }
                        .onAppear { swipeHintPulse = true }

                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.handleSwipe(left: true)
                                isFlipped = false
                            }) {
                                Text("Understood")
                            }
                            .buttonStyle(AppPrimaryButtonStyle())

                            Button(action: {
                                viewModel.handleSwipe(left: false)
                                isFlipped = false
                            }) {
                                Text("Review Later")
                            }
                            .buttonStyle(AppPrimaryButtonStyle())
                        }

                        Button(viewModel.flaggedUnsure.contains(card.id) ? "Remove Unsure Mark" : "Mark Unsure") {
                            viewModel.toggleUnsure()
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                    }

                    NavigationLink(isActive: $showResult) {
                        CompletionResultView(
                            result: AppResultData(
                                title: "Flashcard Flex Result",
                                correctCount: viewModel.understoodCount,
                                incorrectCount: viewModel.revisitCount,
                                stars: viewModel.stars,
                                explanations: ["Review cards marked for revisit to strengthen understanding."],
                                summary: summary
                            ),
                            onNextTopic: {},
                            onReview: {
                                started = false
                                showResult = false
                            }
                        )
                    } label: { EmptyView() }
                }
                .padding(16)
            }
        }
        .navigationTitle("Flashcard Flex")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isCompleted) { completed in
            if completed {
                store.updateActivityBest(activityID: "flashcard-flex", stars: viewModel.stars)
                store.markTopicCompleted(topic.id, stars: viewModel.stars)
                summary = store.recordActivitySession(
                    topicID: topic.id,
                    subjectTitle: topic.title,
                    correct: viewModel.understoodCount,
                    total: max(1, viewModel.cards.count),
                    duration: Date().timeIntervalSince(startedAt)
                )
                let unsureItems = viewModel.flaggedUnsure.map { "Flashcard unsure: \($0)" }
                store.addReviewItems(unsureItems)
                withAnimation { showResult = true }
            }
        }
        .onAppear {
            if !started {
                difficulty = store.recommendedDifficulty(for: "flashcard-flex")
            }
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}

private struct SwipeActionModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .highPriorityGesture(
                DragGesture()
                    .onChanged { offset = $0.translation.width }
                    .onEnded { value in
                        if value.translation.width < -80 {
                            onSwipeLeft()
                        } else if value.translation.width > 80 {
                            onSwipeRight()
                        }
                        withAnimation(.easeInOut(duration: 0.3)) { offset = 0 }
                    }
            )
    }
}

private struct FlashcardHeaderCard: View {
    let current: Int
    let total: Int
    let timeLeft: Int
    let maxTime: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Card \(current) of \(total)")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(timeLeft)s")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appPrimary.opacity(0.35))
                    .clipShape(Capsule())
            }
            ProgressView(value: Double(current), total: Double(max(1, total)))
                .tint(Color.appAccent)
            ProgressView(value: Double(timeLeft), total: Double(max(1, maxTime)))
                .tint(Color.appPrimary)
        }
        .appCardStyle()
    }
}
