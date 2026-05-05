import Foundation

struct Topic: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let lessons: [String]
    let prerequisiteTopicID: String?
}

struct FlashcardItem: Identifiable, Hashable {
    let id: String
    let prompt: String
    let explanation: String
}

struct QuizQuestion: Identifiable, Hashable {
    let id: String
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let miniExample: String
}

struct ActivitySessionSummary {
    let accuracyPercent: Int
    let responseSpeedLabel: String
    let strongestTopic: String
    let nextRecommendation: String
}

struct FillBlankItem: Identifiable, Hashable {
    let id: String
    let sentence: String
    let answer: String
    let hint: String
}

enum ActivityDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }

    var timeLimit: Int {
        switch self {
        case .easy: return 25
        case .medium: return 18
        case .hard: return 12
        }
    }

    var cardMultiplier: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case learn = "Learn"
    case practice = "Practice"
    case progress = "Progress"

    var id: String { rawValue }
}

struct AppResultData {
    let title: String
    let correctCount: Int
    let incorrectCount: Int
    let stars: Int
    let explanations: [String]
    let summary: ActivitySessionSummary?
}

struct OfflineContentPack: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
}

enum SampleLearningData {
    static let topics: [Topic] = [
        Topic(id: "math-algebra", title: "Mathematics", detail: "Linear equations and practical usage.", lessons: ["Variables", "Equations", "Graph interpretation"], prerequisiteTopicID: nil),
        Topic(id: "science-energy", title: "Science", detail: "Energy forms with real-world applications.", lessons: ["Kinetic energy", "Potential energy", "Transformations"], prerequisiteTopicID: "math-algebra"),
        Topic(id: "history-civics", title: "History", detail: "Societal changes across key periods.", lessons: ["Ancient civilizations", "Industrial age", "Modern systems"], prerequisiteTopicID: "science-energy")
    ]

    static let contentPacks: [OfflineContentPack] = [
        OfflineContentPack(id: "pack-math", title: "Mathematics Pack", detail: "Concept explanations, drills, and quizzes."),
        OfflineContentPack(id: "pack-science", title: "Science Pack", detail: "Core theory cards with interactive practice."),
        OfflineContentPack(id: "pack-history", title: "History Pack", detail: "Timeline-based lessons and revision tasks.")
    ]
}
