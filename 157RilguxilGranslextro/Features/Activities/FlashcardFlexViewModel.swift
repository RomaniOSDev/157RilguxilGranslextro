import Combine
import Foundation

final class FlashcardFlexViewModel: ObservableObject {
    @Published var cards: [FlashcardItem]
    @Published var currentIndex = 0
    @Published var remainingTime: Int
    @Published var understoodCount = 0
    @Published var revisitCount = 0
    @Published var isCompleted = false
    @Published var flaggedUnsure: Set<String> = []

    private(set) var difficulty: ActivityDifficulty
    private var cancellable: AnyCancellable?

    init(topic: Topic, difficulty: ActivityDifficulty) {
        self.difficulty = difficulty
        self.cards = []
        self.remainingTime = difficulty.timeLimit
        configure(topic: topic, difficulty: difficulty)
    }

    var currentCard: FlashcardItem? {
        guard cards.indices.contains(currentIndex) else { return nil }
        return cards[currentIndex]
    }

    var stars: Int {
        guard !cards.isEmpty else { return 0 }
        return min(3, (understoodCount * 3) / cards.count)
    }

    func handleSwipe(left: Bool) {
        if left { understoodCount += 1 } else { revisitCount += 1 }
        advance()
    }

    func toggleUnsure() {
        guard let id = currentCard?.id else { return }
        if flaggedUnsure.contains(id) {
            flaggedUnsure.remove(id)
        } else {
            flaggedUnsure.insert(id)
        }
    }

    func stopTimer() {
        cancellable?.cancel()
    }

    func configure(topic: Topic, difficulty: ActivityDifficulty) {
        stopTimer()
        self.difficulty = difficulty
        let baseCards = topic.lessons.enumerated().map { index, lesson in
            FlashcardItem(id: "\(topic.id)-fx-\(index)", prompt: lesson, explanation: "Use the formula in a real-world context.")
        }
        cards = Array(repeating: baseCards, count: difficulty.cardMultiplier).flatMap { $0 }
        currentIndex = 0
        remainingTime = difficulty.timeLimit
        understoodCount = 0
        revisitCount = 0
        isCompleted = false
        flaggedUnsure = []
        startTimer()
    }

    private func advance() {
        if currentIndex + 1 >= cards.count {
            isCompleted = true
            stopTimer()
        } else {
            currentIndex += 1
            remainingTime = difficulty.timeLimit
        }
    }

    private func startTimer() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard !isCompleted else { return }
                if remainingTime == 0 {
                    handleSwipe(left: false)
                } else {
                    remainingTime -= 1
                }
            }
    }
}
