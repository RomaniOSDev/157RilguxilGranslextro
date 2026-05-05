import Combine
import Foundation

final class QuizQuestViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var index = 0
    @Published var selectedIndex: Int?
    @Published var correctAnswers = 0
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var remainingTime: Int = 0
    @Published var completed = false
    @Published var wrongExplanations: [String] = []

    private(set) var difficulty: ActivityDifficulty
    private var timer: AnyCancellable?

    init(topic: Topic, difficulty: ActivityDifficulty) {
        self.difficulty = difficulty
        self.questions = []
        self.remainingTime = difficulty.timeLimit
        configure(topic: topic, difficulty: difficulty)
    }

    var currentQuestion: QuizQuestion? {
        guard questions.indices.contains(index) else { return nil }
        return questions[index]
    }

    var stars: Int {
        guard !questions.isEmpty else { return 0 }
        return min(3, (correctAnswers * 3) / questions.count)
    }

    func choose(_ optionIndex: Int) {
        selectedIndex = optionIndex
    }

    func submitCurrent() {
        guard let question = currentQuestion, let selectedIndex else { return }
        if selectedIndex == question.correctIndex {
            correctAnswers += 1
            alertMessage = "Correct answer."
        } else {
            wrongExplanations.append(question.explanation)
            alertMessage = "Not quite. \(question.explanation)\nWhy this is correct: \(question.miniExample)"
        }
        showAlert = true
    }

    func moveNext() {
        if index + 1 >= questions.count {
            completed = true
            timer?.cancel()
        } else {
            index += 1
            selectedIndex = nil
            remainingTime = difficulty.timeLimit
        }
    }

    func configure(topic: Topic, difficulty: ActivityDifficulty) {
        timer?.cancel()
        self.difficulty = difficulty
        questions = Self.buildQuestions(topic: topic, difficulty: difficulty)
        index = 0
        selectedIndex = nil
        correctAnswers = 0
        showAlert = false
        alertMessage = ""
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
                    wrongExplanations.append(currentQuestion?.explanation ?? "Time expired.")
                    moveNext()
                } else {
                    remainingTime -= 1
                }
            }
    }

    private static func buildQuestions(topic: Topic, difficulty: ActivityDifficulty) -> [QuizQuestion] {
        let base: [QuizQuestion] = [
            QuizQuestion(id: "\(topic.id)-q1", question: "Which statement best summarizes the core concept?", options: ["It focuses only on dates.", "It combines principles and application.", "It avoids examples.", "It is unrelated to school topics."], correctIndex: 1, explanation: "The learning model connects concept and application.", miniExample: "Example: solving a formula and then applying it to a school lab task."),
            QuizQuestion(id: "\(topic.id)-q2", question: "Why is immediate feedback useful?", options: ["It reduces reflection.", "It reinforces understanding quickly.", "It hides mistakes.", "It skips revision."], correctIndex: 1, explanation: "Fast feedback helps students correct reasoning.", miniExample: "Example: seeing the correct method right after a wrong step avoids repeating it."),
            QuizQuestion(id: "\(topic.id)-q3", question: "What supports long-term retention?", options: ["One-time reading", "Repeating key ideas with practice", "Ignoring errors", "Removing examples"], correctIndex: 1, explanation: "Repetition with active practice improves retention.", miniExample: "Example: short daily drills keep the concept active across the week.")
        ]
        switch difficulty {
        case .easy: return base
        case .medium: return base + [base[0]]
        case .hard: return base + [base[0], base[1]]
        }
    }
}
