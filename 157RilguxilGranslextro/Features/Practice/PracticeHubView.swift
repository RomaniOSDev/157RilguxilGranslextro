import SwiftUI

struct PracticeHubView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Practice Center")
                                    .font(.title.bold())
                                    .foregroundStyle(Color.appTextPrimary)

                                Text("Choose a subject and train with interactive activities.")
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                            }
                            Spacer()
                            EducationOrbitIllustration()
                        }
                        .appCardStyle()

                        ForEach(SampleLearningData.topics) { topic in
                            NavigationLink {
                                PracticeTopicActivitiesView(topic: topic)
                            } label: {
                                PracticeTopicCard(topic: topic)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Practice")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

private struct PracticeTopicActivitiesView: View {
    let topic: Topic

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activity Selection")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)

                    NavigationLink {
                        FlashcardFlexView(topic: topic)
                    } label: {
                        ActivityCard(
                            title: "Flashcard Flex",
                            subtitle: "Swipe cards, flag unsure concepts, and build fast recognition.",
                            icon: "rectangle.on.rectangle.angled",
                            badge: "Skill Focus"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        QuizQuestView(topic: topic)
                    } label: {
                        ActivityCard(
                            title: "Quiz Quest",
                            subtitle: "Timed multiple-choice questions with instant feedback.",
                            icon: "checklist",
                            badge: "Accuracy Focus"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        KnowledgeGapsView(topic: topic)
                    } label: {
                        ActivityCard(
                            title: "Knowledge Gaps",
                            subtitle: "Fill missing terms and reinforce key concepts.",
                            icon: "text.cursor",
                            badge: "Retention Focus"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
        }
        .navigationTitle(topic.title)
        .toolbarTitleDisplayMode(.inline)
    }
}

private struct PracticeTopicCard: View {
    let topic: Topic

    var body: some View {
        HStack(spacing: 14) {
            TopicBannerIllustration()

            VStack(alignment: .leading, spacing: 6) {
                Text(topic.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(topic.detail)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.appAccent)
        }
        .appCardStyle()
    }
}

private struct ActivityCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let badge: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appPrimary.opacity(0.25))
                .frame(width: 42, height: 42)
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
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary.opacity(0.18))
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
