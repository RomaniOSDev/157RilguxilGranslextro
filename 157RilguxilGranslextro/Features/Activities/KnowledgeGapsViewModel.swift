import Combine
import Foundation

final class KnowledgeGapsViewModel: ObservableObject {
    @Published var items: [FillBlankItem] = []
    @Published var index = 0
    @Published var textInput = ""
    @Published var correctCount = 0
    @Published var attempts = 0
    @Published var remainingTime = 0
    @Published var completed = false
    @Published var wrongExplanations: [String] = []

    private(set) var difficulty: ActivityDifficulty
    private var timer: AnyCancellable?

    init(topic: Topic, difficulty: ActivityDifficulty) {
        self.difficulty = difficulty
        self.items = []
        self.remainingTime = difficulty.timeLimit
        configure(topic: topic, difficulty: difficulty)
    }

    var currentItem: FillBlankItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    var stars: Int {
        guard !items.isEmpty else { return 0 }
        return min(3, (correctCount * 3) / items.count)
    }

    func submit() {
        guard let currentItem else { return }
        attempts += 1
        let normalized = textInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == currentItem.answer.lowercased() {
            correctCount += 1
        } else {
            wrongExplanations.append("Correct term for '\(currentItem.sentence)' is '\(currentItem.answer)'.")
        }
        moveNext()
    }

    func moveNext() {
        textInput = ""
        if index + 1 >= items.count {
            completed = true
            timer?.cancel()
        } else {
            index += 1
            remainingTime = difficulty.timeLimit
        }
    }

    func configure(topic: Topic, difficulty: ActivityDifficulty) {
        timer?.cancel()
        self.difficulty = difficulty
        items = Self.buildItems(topic: topic, difficulty: difficulty)
        index = 0
        textInput = ""
        correctCount = 0
        attempts = 0
        remainingTime = difficulty.timeLimit
        completed = false
        wrongExplanations = []
        startTimer()
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard !completed else { return }
                if remainingTime <= 0 {
                    wrongExplanations.append("Time ran out on a sentence.")
                    moveNext()
                } else {
                    remainingTime -= 1
                }
            }
    }

    private static func buildItems(topic: Topic, difficulty: ActivityDifficulty) -> [FillBlankItem] {
        let base = [
            FillBlankItem(id: "\(topic.id)-f1", sentence: "A core idea can be applied to a ___ problem.", answer: "real-world", hint: "It connects school and life."),
            FillBlankItem(id: "\(topic.id)-f2", sentence: "Frequent practice improves long-term ___.", answer: "retention", hint: "It means keeping knowledge."),
            FillBlankItem(id: "\(topic.id)-f3", sentence: "Immediate feedback supports faster ___.", answer: "correction", hint: "Think fixing mistakes quickly.")
        ]
        switch difficulty {
        case .easy: return base
        case .medium: return base + [base[0]]
        case .hard: return base + [base[0], base[1]]
        }
    }
}
