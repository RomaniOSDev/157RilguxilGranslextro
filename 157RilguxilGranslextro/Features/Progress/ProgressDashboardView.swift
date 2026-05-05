import SwiftUI

struct ProgressDashboardView: View {
    @EnvironmentObject private var store: LearningDataStore
    @State private var teacherMode = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Progress")
                            .font(.title.bold())
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        EducationOrbitIllustration()
                    }
                    .appCardStyle()

                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack {
                            Text("Open Settings")
                                .foregroundStyle(Color.appTextPrimary)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.appAccent)
                        }
                        .appCardStyle()
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Stars: \(store.totalStars)")
                        Text("Lessons Completed: \(store.lessonsCompleted)")
                        Text("Current Course: \(store.currentCourse)")
                        Text("Daily Goal: \(store.dailyProgress)/\(store.dailyGoalTarget)")
                        Text("Current Streak: \(store.streakCount) day(s)")
                    }
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardStyle()

                    Stepper("Daily Goal Target: \(store.dailyGoalTarget)", value: $store.dailyGoalTarget, in: 1...6)
                        .foregroundStyle(Color.appTextPrimary)
                        .appCardStyle()

                    if !store.weakTopics.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Needs Review")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            ForEach(store.weakTopics) { topic in
                                Text("• \(topic.title) (\(store.topicStars[topic.id] ?? 0) stars)")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Achievements")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        ForEach(store.achievements, id: \.self) { item in
                            Text("• \(item)")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Best Scores")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        if store.activityBestScores.isEmpty {
                            Text("Complete activities to see your best stars.")
                                .foregroundStyle(Color.appTextSecondary)
                        } else {
                            ForEach(store.activityBestScores.keys.sorted(), id: \.self) { key in
                                Text("\(key): \(store.activityBestScores[key] ?? 0) stars")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardStyle()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Offline Content Packs")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        ForEach(SampleLearningData.contentPacks) { pack in
                            Toggle(
                                "\(pack.title) \(store.downloadedPacks.contains(pack.id) ? "• Downloaded" : "• Not Downloaded")",
                                isOn: Binding(
                                    get: { store.downloadedPacks.contains(pack.id) },
                                    set: { store.markPackDownloaded(pack.id, downloaded: $0) }
                                )
                            )
                            .toggleStyle(.switch)
                            .tint(Color.appPrimary)
                            .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardStyle()

                    Toggle("Teacher / Parent Mode", isOn: $teacherMode)
                        .tint(Color.appPrimary)
                        .foregroundStyle(Color.appTextPrimary)
                        .appCardStyle()

                    if teacherMode {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Local Subject Report")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            if store.teacherDailySubjectStats.isEmpty {
                                Text("No sessions recorded yet.")
                                    .foregroundStyle(Color.appTextSecondary)
                            } else {
                                ForEach(store.teacherDailySubjectStats, id: \.subject) { item in
                                    Text("\(item.subject): \(item.sessions) sessions")
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }

                    Button("Reset All Progress") {
                        store.resetAllProgress()
                    }
                    .buttonStyle(AppPrimaryButtonStyle())
                }
                .padding(16)
            }
            .appScreenBackground()
            .navigationTitle("Progress")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}
