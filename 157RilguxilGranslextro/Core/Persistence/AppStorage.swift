import Foundation
import SwiftUI
import Combine

final class LearningDataStore: ObservableObject {
    @AppStorage("totalStars") var totalStars: Int = 0
    @AppStorage("lessonsCompleted") var lessonsCompleted: Int = 0
    @AppStorage("currentCourse") var currentCourse: String = "Mathematics"
    @AppStorage("completedTopicsRaw") private var completedTopicsRaw: String = ""
    @AppStorage("topicStarsRaw") private var topicStarsRaw: String = ""
    @AppStorage("activityBestRaw") private var activityBestRaw: String = ""
    @AppStorage("topicAttemptsRaw") private var topicAttemptsRaw: String = ""
    @AppStorage("topicCorrectRaw") private var topicCorrectRaw: String = ""
    @AppStorage("reviewQueueRaw") private var reviewQueueRaw: String = ""
    @AppStorage("dailyGoalTarget") var dailyGoalTarget: Int = 2
    @AppStorage("dailyGoalDate") private var dailyGoalDate: String = ""
    @AppStorage("dailyGoalProgress") private var dailyGoalProgress: Int = 0
    @AppStorage("streakCount") var streakCount: Int = 0
    @AppStorage("lastActiveDate") private var lastActiveDate: String = ""
    @AppStorage("subjectDailyRaw") private var subjectDailyRaw: String = ""
    @AppStorage("downloadedPacksRaw") private var downloadedPacksRaw: String = ""

    let didResetNotification = Notification.Name("LearningDataStoreDidReset")

    var completedTopics: Set<String> {
        get { Set(completedTopicsRaw.split(separator: "|").map(String.init)) }
        set { completedTopicsRaw = newValue.sorted().joined(separator: "|") }
    }

    var topicStars: [String: Int] {
        get { decodeDictionary(topicStarsRaw) }
        set { topicStarsRaw = encodeDictionary(newValue) }
    }

    var activityBestScores: [String: Int] {
        get { decodeDictionary(activityBestRaw) }
        set { activityBestRaw = encodeDictionary(newValue) }
    }

    var topicAttempts: [String: Int] {
        get { decodeDictionary(topicAttemptsRaw) }
        set { topicAttemptsRaw = encodeDictionary(newValue) }
    }

    var topicCorrect: [String: Int] {
        get { decodeDictionary(topicCorrectRaw) }
        set { topicCorrectRaw = encodeDictionary(newValue) }
    }

    var reviewQueue: [String] {
        get { reviewQueueRaw.split(separator: "|").map(String.init) }
        set { reviewQueueRaw = Array(Set(newValue)).sorted().joined(separator: "|") }
    }

    var downloadedPacks: Set<String> {
        get { Set(downloadedPacksRaw.split(separator: "|").map(String.init)) }
        set { downloadedPacksRaw = newValue.sorted().joined(separator: "|") }
    }

    var dailyProgress: Int {
        return dailyGoalProgress
    }

    var dailyGoalCompleted: Bool {
        dailyProgress >= dailyGoalTarget
    }

    var weakTopics: [Topic] {
        SampleLearningData.topics.filter { (topicStars[$0.id] ?? 0) < 2 }
    }

    var adaptiveRecommendation: Topic? {
        let sortedByWeakness = SampleLearningData.topics.sorted {
            weaknessScore(for: $0.id) > weaknessScore(for: $1.id)
        }
        return sortedByWeakness.first
    }

    var teacherDailySubjectStats: [(subject: String, sessions: Int)] {
        let pairs = subjectDailyRaw.split(separator: "|")
        let map = pairs.reduce(into: [String: Int]()) { partial, pair in
            let parts = pair.split(separator: "=")
            if parts.count == 2, let value = Int(parts[1]) {
                partial[String(parts[0])] = value
            }
        }
        return map.keys.sorted().map { ($0, map[$0] ?? 0) }
    }

    var achievements: [String] {
        var output: [String] = []
        if lessonsCompleted >= 3 { output.append("Consistent Learner") }
        if totalStars >= 15 { output.append("Star Collector") }
        if completedTopics.count >= 3 { output.append("Topic Explorer") }
        if output.isEmpty { output.append("Your next achievement is close.") }
        return output
    }

    func markTopicCompleted(_ id: String, stars: Int) {
        var nextCompleted = completedTopics
        nextCompleted.insert(id)
        completedTopics = nextCompleted

        var nextStars = topicStars
        let value = max(nextStars[id] ?? 0, min(3, max(0, stars)))
        nextStars[id] = value
        topicStars = nextStars

        totalStars = max(totalStars, nextStars.values.reduce(0, +))
        lessonsCompleted = completedTopics.count
        incrementDailyGoalProgress()
        objectWillChange.send()
    }

    func updateActivityBest(activityID: String, stars: Int) {
        var next = activityBestScores
        next[activityID] = max(next[activityID] ?? 0, min(3, max(0, stars)))
        activityBestScores = next
        totalStars = max(totalStars, next.values.reduce(0, +), topicStars.values.reduce(0, +))
        objectWillChange.send()
    }

    func addReviewItems(_ items: [String]) {
        var queue = reviewQueue
        queue.append(contentsOf: items)
        reviewQueue = queue
        objectWillChange.send()
    }

    func clearReviewItem(_ item: String) {
        reviewQueue = reviewQueue.filter { $0 != item }
        objectWillChange.send()
    }

    func markPackDownloaded(_ packID: String, downloaded: Bool) {
        var packs = downloadedPacks
        if downloaded {
            packs.insert(packID)
        } else {
            packs.remove(packID)
        }
        downloadedPacks = packs
        objectWillChange.send()
    }

    func recommendedDifficulty(for activityID: String) -> ActivityDifficulty {
        let performance = activityBestScores[activityID] ?? 0
        if performance >= 3 { return .hard }
        if performance >= 2 { return .medium }
        return .easy
    }

    func recordActivitySession(topicID: String, subjectTitle: String, correct: Int, total: Int, duration: TimeInterval) -> ActivitySessionSummary {
        var attempts = topicAttempts
        attempts[topicID] = (attempts[topicID] ?? 0) + total
        topicAttempts = attempts

        var correctMap = topicCorrect
        correctMap[topicID] = (correctMap[topicID] ?? 0) + correct
        topicCorrect = correctMap

        incrementSubjectStat(subjectTitle)
        incrementDailyGoalProgress()

        let accuracy = total > 0 ? Int((Double(correct) / Double(total)) * 100) : 0
        let speed: String
        let average = total > 0 ? duration / Double(total) : duration
        if average < 7 {
            speed = "Fast"
        } else if average < 14 {
            speed = "Balanced"
        } else {
            speed = "Careful"
        }

        let strong = strongestTopicTitle()
        let recommendation = adaptiveRecommendation?.title ?? subjectTitle
        objectWillChange.send()
        return ActivitySessionSummary(
            accuracyPercent: accuracy,
            responseSpeedLabel: speed,
            strongestTopic: strong,
            nextRecommendation: "Next recommended topic: \(recommendation)"
        )
    }

    func resetAllProgress() {
        let defaults = UserDefaults.standard
        [
            "totalStars",
            "lessonsCompleted",
            "currentCourse",
            "completedTopicsRaw",
            "topicStarsRaw",
            "activityBestRaw",
            "topicAttemptsRaw",
            "topicCorrectRaw",
            "reviewQueueRaw",
            "dailyGoalTarget",
            "dailyGoalDate",
            "dailyGoalProgress",
            "streakCount",
            "lastActiveDate",
            "subjectDailyRaw",
            "downloadedPacksRaw",
            "hasSeenOnboarding"
        ].forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()

        totalStars = 0
        lessonsCompleted = 0
        currentCourse = "Mathematics"
        completedTopicsRaw = ""
        topicStarsRaw = ""
        activityBestRaw = ""
        topicAttemptsRaw = ""
        topicCorrectRaw = ""
        reviewQueueRaw = ""
        dailyGoalTarget = 2
        dailyGoalDate = ""
        dailyGoalProgress = 0
        streakCount = 0
        lastActiveDate = ""
        subjectDailyRaw = ""
        downloadedPacksRaw = ""

        NotificationCenter.default.post(name: didResetNotification, object: nil)
        objectWillChange.send()
    }

    func syncDailyStateIfNeeded() {
        if refreshDailyGoalIfNeeded() {
            objectWillChange.send()
        }
    }

    private func encodeDictionary(_ dictionary: [String: Int]) -> String {
        dictionary.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: "|")
    }

    private func decodeDictionary(_ value: String) -> [String: Int] {
        var output: [String: Int] = [:]
        let pairs = value.split(separator: "|")
        for pair in pairs {
            let parts = pair.split(separator: "=")
            if parts.count == 2, let intValue = Int(parts[1]) {
                output[String(parts[0])] = intValue
            }
        }
        return output
    }

    private func incrementDailyGoalProgress() {
        _ = refreshDailyGoalIfNeeded()
        dailyGoalProgress += 1
        if dailyGoalProgress == dailyGoalTarget {
            updateStreak()
        }
    }

    private func refreshDailyGoalIfNeeded() -> Bool {
        let today = dateString(for: Date())
        if dailyGoalDate != today {
            dailyGoalDate = today
            dailyGoalProgress = 0
            return true
        }
        return false
    }

    private func updateStreak() {
        let today = Date()
        let todayString = dateString(for: today)
        if lastActiveDate.isEmpty {
            streakCount = 1
            lastActiveDate = todayString
            return
        }
        guard let lastDate = date(from: lastActiveDate) else {
            streakCount = 1
            lastActiveDate = todayString
            return
        }
        let diff = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastDate), to: Calendar.current.startOfDay(for: today)).day ?? 0
        if diff == 1 {
            streakCount += 1
        } else if diff > 1 {
            streakCount = 1
        }
        lastActiveDate = todayString
    }

    private func incrementSubjectStat(_ title: String) {
        var map = subjectDailyRaw.split(separator: "|").reduce(into: [String: Int]()) { partial, pair in
            let parts = pair.split(separator: "=")
            if parts.count == 2, let value = Int(parts[1]) {
                partial[String(parts[0])] = value
            }
        }
        map[title] = (map[title] ?? 0) + 1
        subjectDailyRaw = map.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: "|")
    }

    private func strongestTopicTitle() -> String {
        let topics = SampleLearningData.topics
        let best = topics.max { lhs, rhs in
            topicAccuracy(for: lhs.id) < topicAccuracy(for: rhs.id)
        }
        return best?.title ?? currentCourse
    }

    private func weaknessScore(for topicID: String) -> Double {
        let stars = Double(topicStars[topicID] ?? 0)
        let accuracy = topicAccuracy(for: topicID)
        return (3 - stars) + (1 - accuracy)
    }

    private func topicAccuracy(for topicID: String) -> Double {
        let attempts = Double(topicAttempts[topicID] ?? 0)
        guard attempts > 0 else { return 0.5 }
        let correct = Double(topicCorrect[topicID] ?? 0)
        return correct / attempts
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func date(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
