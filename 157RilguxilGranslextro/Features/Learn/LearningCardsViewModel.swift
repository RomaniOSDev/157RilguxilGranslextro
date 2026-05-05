import Foundation
import Combine

final class LearningCardsViewModel: ObservableObject {
    @Published var cards: [FlashcardItem] = []
    @Published var revealedCardID: String?

    init(topic: Topic) {
        cards = topic.lessons.enumerated().map { index, lesson in
            FlashcardItem(
                id: "\(topic.id)-\(index)",
                prompt: lesson,
                explanation: "This concept is explained with a practical high-school example."
            )
        }
    }

    func toggle(cardID: String) {
        revealedCardID = revealedCardID == cardID ? nil : cardID
    }
}
