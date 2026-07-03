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
    @Published var currentAnswers: [String] = [] // Holds the answers for the current question so they don't reshuffle on UI updates
    
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var longestStreak: Int = 0
    
    // Timer properties
    @Published var timeRemaining: Int = 20
    private var timerCancellable: AnyCancellable?
    
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
        stopTimer()
        
        do {
            let fetchedQuestions = try await TriviaService.fetchQuestions()
            self.questions = fetchedQuestions
            if !self.questions.isEmpty {
                self.currentAnswers = self.questions[0].allAnswers
            }
            self.viewState = .loaded
            self.startTimer()
        } catch {
            self.viewState = .failed
        }
    }
    
    func startTimer() {
        timeRemaining = 20
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isAnswerLocked, self.viewState == .loaded else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.handleTimeout()
                }
            }
    }
    
    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func handleTimeout() {
        guard !isAnswerLocked else { return }
        isAnswerLocked = true
        
        // Timeout penalty
        streak = 0
        score = max(0, score - 2)
        isAnswerCorrect = false
        // No selected answer, so it highlights the correct one
        
        advanceToNextQuestionWithDelay()
    }
    
    func submitAnswer(_ answer: String) {
        guard !isAnswerLocked else { return }
        stopTimer()
        
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
        
        advanceToNextQuestionWithDelay()
    }
    
    private func advanceToNextQuestionWithDelay() {
        // Delay to show color flash animation, then advance
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 second delay
            
            selectedAnswer = nil
            isAnswerCorrect = nil
            isAnswerLocked = false
            
            if currentIndex < questions.count - 1 {
                currentIndex += 1
                currentAnswers = questions[currentIndex].allAnswers // Shuffle once for the new question
                startTimer() // Restart timer for the next question
            } else {
                viewState = .completed
            }
        }
    }
}
