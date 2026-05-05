import Foundation
import Combine

final class LearnViewModel: ObservableObject {
    @Published var topicUnlockStates: [String: Bool] = [:]
    let topics: [Topic] = SampleLearningData.topics

    init() {
        topics.forEach { topicUnlockStates[$0.id] = false }
        if let first = topics.first {
            topicUnlockStates[first.id] = true
        }
    }

    func isUnlocked(_ topic: Topic, completed: Set<String>) -> Bool {
        guard let prerequisite = topic.prerequisiteTopicID else {
            return topicUnlockStates[topic.id] ?? true
        }
        return completed.contains(prerequisite) && (topicUnlockStates[topic.id] ?? false)
    }

    func progress(for topic: Topic, in store: LearningDataStore) -> Double {
        Double(store.topicStars[topic.id] ?? 0) / 3.0
    }
}
