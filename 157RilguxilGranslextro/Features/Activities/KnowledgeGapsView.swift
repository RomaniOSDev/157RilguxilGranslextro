import SwiftUI

struct KnowledgeGapsView: View {
    @EnvironmentObject private var store: LearningDataStore
    let topic: Topic
    @State private var difficulty: ActivityDifficulty = .easy
    @State private var started = false
    @StateObject private var viewModel: KnowledgeGapsViewModel
    @State private var showResult = false
    @State private var summary: ActivitySessionSummary?
    @State private var startedAt = Date()

    init(topic: Topic) {
        self.topic = topic
        _viewModel = StateObject(wrappedValue: KnowledgeGapsViewModel(topic: topic, difficulty: .easy))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !started {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(ActivityDifficulty.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .appCardStyle()

                    Button("Start Fill-In Activity") {
                        viewModel.configure(topic: topic, difficulty: difficulty)
                        started = true
                        startedAt = Date()
                    }
                    .buttonStyle(AppPrimaryButtonStyle())
                } else if let item = viewModel.currentItem {
                    Text("Time left: \(viewModel.remainingTime)s")
                        .foregroundStyle(Color.appTextPrimary)

                    LazyHStack {
                        Text(item.sentence.replacingOccurrences(of: "___", with: "_____"))
                            .foregroundStyle(Color.appTextPrimary)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardStyle()

                    TextField("Type the missing term", text: $viewModel.textInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(16)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .onSubmit { viewModel.submit() }

                    HStack {
                        Text("Attempts: \(viewModel.attempts)")
                        ProgressView(value: Double(viewModel.correctCount), total: Double(max(1, viewModel.items.count)))
                            .tint(Color.appAccent)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                    .appCardStyle()

                    Button("Submit", action: viewModel.submit)
                        .buttonStyle(AppPrimaryButtonStyle())
                }

                NavigationLink(isActive: $showResult) {
                    CompletionResultView(
                        result: AppResultData(
                            title: "Knowledge Gaps Result",
                            correctCount: viewModel.correctCount,
                            incorrectCount: max(0, viewModel.items.count - viewModel.correctCount),
                            stars: viewModel.stars,
                            explanations: viewModel.wrongExplanations.isEmpty ? ["Excellent completion speed and accuracy."] : viewModel.wrongExplanations,
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
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Knowledge Gaps")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: viewModel.completed) { completed in
            if completed {
                store.updateActivityBest(activityID: "knowledge-gaps", stars: viewModel.stars)
                store.markTopicCompleted(topic.id, stars: viewModel.stars)
                summary = store.recordActivitySession(
                    topicID: topic.id,
                    subjectTitle: topic.title,
                    correct: viewModel.correctCount,
                    total: max(1, viewModel.items.count),
                    duration: Date().timeIntervalSince(startedAt)
                )
                store.addReviewItems(viewModel.wrongExplanations.map { "Fill-in: \($0)" })
                withAnimation { showResult = true }
            }
        }
        .onAppear {
            if !started {
                difficulty = store.recommendedDifficulty(for: "knowledge-gaps")
            }
        }
    }
}
