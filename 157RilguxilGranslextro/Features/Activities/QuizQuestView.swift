import SwiftUI

struct QuizQuestView: View {
    @EnvironmentObject private var store: LearningDataStore
    let topic: Topic
    @State private var difficulty: ActivityDifficulty = .easy
    @State private var started = false
    @StateObject private var viewModel: QuizQuestViewModel
    @State private var showResult = false
    @State private var summary: ActivitySessionSummary?
    @State private var startedAt = Date()

    init(topic: Topic) {
        self.topic = topic
        _viewModel = StateObject(wrappedValue: QuizQuestViewModel(topic: topic, difficulty: .easy))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        if !started {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Difficulty")
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

                            Button("Start Quiz") {
                                viewModel.configure(topic: topic, difficulty: difficulty)
                                started = true
                                startedAt = Date()
                            }
                            .buttonStyle(AppPrimaryButtonStyle())
                        } else if let question = viewModel.currentQuestion {
                            QuizHeaderCard(
                                questionNumber: viewModel.index + 1,
                                totalQuestions: max(1, viewModel.questions.count),
                                timeLeft: viewModel.remainingTime,
                                maxTime: viewModel.difficulty.timeLimit
                            )

                            VStack(alignment: .leading, spacing: 14) {
                                Text(question.question)
                                    .foregroundStyle(Color.appTextPrimary)
                                    .font(.title3.weight(.semibold))
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.7)

                                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                    QuizOptionRow(
                                        title: option,
                                        letter: optionLetter(for: index),
                                        isSelected: viewModel.selectedIndex == index
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            viewModel.choose(index)
                                        }
                                    }
                                }
                            }
                            .appCardStyle()
                            .transition(.slide)

                            Button("Submit Answer", action: viewModel.submitCurrent)
                                .buttonStyle(AppPrimaryButtonStyle())
                            .disabled(viewModel.selectedIndex == nil)
                            .opacity(viewModel.selectedIndex == nil ? 0.6 : 1)
                        }

                        NavigationLink(isActive: $showResult) {
                            CompletionResultView(
                                result: AppResultData(
                                    title: "Quiz Quest Result",
                                    correctCount: viewModel.correctAnswers,
                                    incorrectCount: max(0, viewModel.questions.count - viewModel.correctAnswers),
                                    stars: viewModel.stars,
                                    explanations: viewModel.wrongExplanations.isEmpty ? ["Strong accuracy across all questions."] : viewModel.wrongExplanations,
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
            .navigationTitle("Quiz Quest")
            .toolbarTitleDisplayMode(.inline)
        }
        .onChange(of: viewModel.completed) { completed in
            if completed {
                store.updateActivityBest(activityID: "quiz-quest", stars: viewModel.stars)
                store.markTopicCompleted(topic.id, stars: viewModel.stars)
                summary = store.recordActivitySession(
                    topicID: topic.id,
                    subjectTitle: topic.title,
                    correct: viewModel.correctAnswers,
                    total: max(1, viewModel.questions.count),
                    duration: Date().timeIntervalSince(startedAt)
                )
                let reviewItems = viewModel.wrongExplanations.map { "Quiz: \($0)" }
                store.addReviewItems(reviewItems)
                withAnimation { showResult = true }
            }
        }
        .onAppear {
            if !started {
                difficulty = store.recommendedDifficulty(for: "quiz-quest")
            }
        }
        .alert("Feedback", isPresented: $viewModel.showAlert) {
            Button("Continue") { viewModel.moveNext() }
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    private func optionLetter(for index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return letters.indices.contains(index) ? letters[index] : "•"
    }
}

private struct QuizHeaderCard: View {
    let questionNumber: Int
    let totalQuestions: Int
    let timeLeft: Int
    let maxTime: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Question \(questionNumber) of \(totalQuestions)")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Stay focused and answer before time runs out.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                Text("\(timeLeft)s")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appPrimary.opacity(0.35))
                    .clipShape(Capsule())
            }

            ProgressView(value: Double(timeLeft), total: Double(max(1, maxTime)))
                .tint(Color.appAccent)
        }
        .appCardStyle()
    }
}

private struct QuizOptionRow: View {
    let title: String
    let letter: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(letter)
                .font(.headline)
                .foregroundStyle(isSelected ? Color.appTextPrimary : Color.appAccent)
                .frame(width: 34, height: 34)
                .background(isSelected ? Color.appPrimary : Color.appSurface)
                .clipShape(Circle())

            Text(title)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.appAccent : Color.appTextSecondary)
        }
        .padding(12)
        .background(isSelected ? Color.appPrimary.opacity(0.2) : Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
