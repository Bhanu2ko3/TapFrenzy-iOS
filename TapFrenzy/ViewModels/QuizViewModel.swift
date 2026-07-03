import Foundation
import Combine

enum QuizViewState {
    case loading
    case loaded
    case failed
    case completed
}

@MainActor
class QuizViewModel: ObservableObject {
    @Published var viewState: QuizViewState = .loading
    @Published var questions: [TriviaQuestion] = []
    
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var longestStreak: Int = 0
    
    // Animation properties
    @Published var selectedAnswer: String? = nil
    @Published var isAnswerCorrect: Bool? = nil
    @Published var isAnswerLocked: Bool = false
    
    func loadGame() async {
        viewState = .loading
        currentIndex = 0
        score = 0
        streak = 0
        longestStreak = 0
        
        do {
            let fetchedQuestions = try await TriviaService.fetchQuestions()
            self.questions = fetchedQuestions
            self.viewState = .loaded
        } catch {
            self.viewState = .failed
        }
    }
    
    func submitAnswer(_ answer: String) {
        guard !isAnswerLocked else { return }
        isAnswerLocked = true
        selectedAnswer = answer
        
        let currentQuestion = questions[currentIndex]
        let isCorrect = (answer == currentQuestion.decodedCorrectAnswer)
        self.isAnswerCorrect = isCorrect
        
        if isCorrect {
            score += 10
            streak += 1
            if streak > longestStreak { longestStreak = streak }
            // Bonus points for streaks
            if streak >= 3 { score += 5 }
        } else {
            score = max(0, score - 2) // small penalty
            streak = 0
        }
        
        // Delay to show color flash animation, then advance
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            selectedAnswer = nil
            isAnswerCorrect = nil
            isAnswerLocked = false
            
            if currentIndex < questions.count - 1 {
                currentIndex += 1
            } else {
                viewState = .completed
            }
        }
    }
}
