import SwiftUI

struct LearnHomeView: View {
    @EnvironmentObject private var store: LearningDataStore
    @StateObject private var viewModel = LearnViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HomeHeroWidget(
                            dailyProgress: store.dailyProgress,
                            dailyGoal: store.dailyGoalTarget,
                            streak: store.streakCount,
                            stars: store.totalStars
                        )

                        HomeStatsWidget(
                            dailyProgress: store.dailyProgress,
                            dailyGoal: store.dailyGoalTarget,
                            streak: store.streakCount
                        )

                        if let recommendation = store.adaptiveRecommendation {
                            NavigationLink {
                                TopicDetailView(topic: recommendation, isUnlocked: true)
                            } label: {
                                AdaptivePlanWidget(topic: recommendation)
                            }
                            .buttonStyle(.plain)
                        }

                        if !store.reviewQueue.isEmpty {
                            ReviewTodayWidget(items: Array(store.reviewQueue.prefix(4))) { item in
                                store.clearReviewItem(item)
                            }
                        }

                        HomeAchievementsWidget(items: store.achievements)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Quick Actions")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            HStack(spacing: 12) {
                                NavigationLink {
                                    TopicCatalogView(viewModel: viewModel, searchText: $searchText)
                                } label: {
                                    HomeQuickAction(title: "Topics", icon: "list.bullet.rectangle")
                                }
                                .buttonStyle(.plain)

                                NavigationLink {
                                    PracticeHubView()
                                } label: {
                                    HomeQuickAction(title: "Practice", icon: "bolt.fill")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .appCardStyle()

                        NavigationLink {
                            TopicCatalogView(viewModel: viewModel, searchText: $searchText)
                        } label: {
                            HStack {
                                Text("Open Topic Library")
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer()
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                            }
                            .appCardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Learn")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

private struct TopicCatalogView: View {
    @EnvironmentObject private var store: LearningDataStore
    @ObservedObject var viewModel: LearnViewModel
    @Binding var searchText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(filteredTopics) { topic in
                    let unlocked = viewModel.isUnlocked(topic, completed: store.completedTopics)
                    NavigationLink {
                        TopicDetailView(topic: topic, isUnlocked: unlocked)
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(topic.title)
                                    .foregroundStyle(Color.appTextPrimary)
                                    .font(.headline)
                                Spacer()
                                if store.completedTopics.contains(topic.id) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(Color.appAccent)
                                }
                            }

                            Text(topic.detail)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)

                            ProgressView(value: viewModel.progress(for: topic, in: store))
                                .tint(Color.appAccent)
                                .background(Color.appSurface)

                            Toggle("Unlock Topic", isOn: Binding(
                                get: { viewModel.topicUnlockStates[topic.id] ?? false },
                                set: { viewModel.topicUnlockStates[topic.id] = $0 }
                            ))
                            .toggleStyle(.switch)
                            .disabled(topic.prerequisiteTopicID != nil && !store.completedTopics.contains(topic.prerequisiteTopicID ?? ""))
                            .tint(Color.appPrimary)
                            .foregroundStyle(Color.appTextPrimary)
                        }
                        .appCardStyle()
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Topic Library")
        .toolbarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search in lessons")
    }

    private var filteredTopics: [Topic] {
        guard !searchText.isEmpty else { return viewModel.topics }
        let term = searchText.lowercased()
        return viewModel.topics.filter { topic in
            topic.title.lowercased().contains(term)
            || topic.detail.lowercased().contains(term)
            || topic.lessons.contains(where: { $0.lowercased().contains(term) })
        }
    }
}

private struct TopicDetailView: View {
    @EnvironmentObject private var store: LearningDataStore
    let topic: Topic
    let isUnlocked: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(topic.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text(topic.detail)
                    .foregroundStyle(Color.appTextSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Lesson Path")
                        .foregroundStyle(Color.appTextPrimary)
                        .font(.headline)
                    ForEach(topic.lessons, id: \.self) { lesson in
                        Text("• \(lesson)")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .appCardStyle()

                NavigationLink {
                    LearningCardsView(topic: topic)
                } label: {
                    Text("Open Learning Cards")
                }
                .buttonStyle(AppPrimaryButtonStyle())

                NavigationLink {
                    ActivityPickerView(topic: topic)
                } label: {
                    Text("Start Activities")
                }
                .buttonStyle(AppPrimaryButtonStyle())

                if !isUnlocked {
                    Text("Complete the previous topic to unlock this section.")
                        .foregroundStyle(Color.appTextSecondary)
                        .appCardStyle()
                }
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Topic")
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            store.currentCourse = topic.title
        }
    }
}

private struct ActivityPickerView: View {
    let topic: Topic

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select an activity style")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)

                    NavigationLink {
                        FlashcardFlexView(topic: topic)
                    } label: {
                        LearningActivityCard(
                            title: "Flashcard Flex",
                            subtitle: "Swipe through cards to confirm understanding.",
                            icon: "rectangle.stack",
                            accent: "Dynamic"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        QuizQuestView(topic: topic)
                    } label: {
                        LearningActivityCard(
                            title: "Quiz Quest",
                            subtitle: "Challenge your timing and answer precision.",
                            icon: "list.clipboard",
                            accent: "Timed"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        KnowledgeGapsView(topic: topic)
                    } label: {
                        LearningActivityCard(
                            title: "Knowledge Gaps",
                            subtitle: "Complete missing terms to reinforce retention.",
                            icon: "textformat.abc.dottedunderline",
                            accent: "Focused"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
        }
        .navigationTitle("Practice")
        .toolbarTitleDisplayMode(.inline)
    }
}

private struct LearningActivityCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.appPrimary.opacity(0.23))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: icon)
                        .foregroundStyle(Color.appAccent)
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(accent)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text(subtitle)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .appCardStyle()
    }
}

private struct HomeStatsWidget: View {
    let dailyProgress: Int
    let dailyGoal: Int
    let streak: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Focus")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 10) {
                HomeMiniMetric(title: "Goal", value: "\(dailyProgress)/\(dailyGoal)", icon: "target")
                HomeMiniMetric(title: "Streak", value: "\(streak) days", icon: "flame.fill")
            }
            ProgressView(value: Double(dailyProgress), total: Double(max(1, dailyGoal)))
                .tint(Color.appAccent)
        }
        .appCardStyle()
    }
}

private struct AdaptivePlanWidget: View {
    let topic: Topic

    var body: some View {
        HStack(spacing: 12) {
            TopicBannerIllustration()
            VStack(alignment: .leading, spacing: 4) {
                Text("Adaptive Study Plan")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text("Recommended next focus: \(topic.title)")
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appAccent)
        }
        .appCardStyle()
    }
}

private struct ReviewTodayWidget: View {
    let items: [String]
    let onDone: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Review Today")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(Color.appAccent)
            }
            ForEach(items, id: \.self) { item in
                HStack {
                    Text("• \(item)")
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Button("Done") { onDone(item) }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
        .appCardStyle()
    }
}

private struct HomeQuickAction: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.22))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
            }
            Text(title)
                .foregroundStyle(Color.appTextPrimary)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
        )
    }
}

private struct HomeHeroWidget: View {
    let dailyProgress: Int
    let dailyGoal: Int
    let streak: Int
    let stars: Int
    @State private var glow = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Home")
                        .font(.title.bold())
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Build confidence with focused practice every day.")
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                EducationOrbitIllustration()
            }

            HStack(spacing: 12) {
                HomeHeroBadge(title: "Stars", value: "\(stars)")
                HomeHeroBadge(title: "Goal", value: "\(dailyProgress)/\(dailyGoal)")
                HomeHeroBadge(title: "Streak", value: "\(streak)")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurface)
                .shadow(color: Color.appPrimary.opacity(glow ? 0.45 : 0.2), radius: glow ? 16 : 6)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}

private struct HomeHeroBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .background(Color.appPrimary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct HomeMiniMetric: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.appAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .foregroundStyle(Color.appTextPrimary)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .foregroundStyle(Color.appTextSecondary)
                    .font(.caption)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.appSurface.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct HomeAchievementsWidget: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.appAccent)
            }
            ForEach(items.prefix(3), id: \.self) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 8, height: 8)
                    Text(item)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .appCardStyle()
    }
}
