import SwiftUI
import Combine

enum NetworkState {
    case loading
    case active
    case error
}

@MainActor
class QuizEngineVM: ObservableObject {
    @Published var networkState: NetworkState = .loading
    @Published var questionList: [TriviaQuestion] = []
    @Published var currentActiveIndex: Int = 0
    @Published var runningScore: Int = 0
    @Published var consecutiveStreak: Int = 0
    @Published var currentAnswers: [String] = []
    
    @Published var timeRemaining: Int = 20
    @Published var selectedAnswer: String? = nil
    @Published var isAnswerCorrect: Bool? = nil
    @Published var isAnswerLocked: Bool = false
    @Published var gameIsCompleted: Bool = false
    
    private var timerCancellable: AnyCancellable?
    
    func loadGame() async {
        networkState = .loading
        currentActiveIndex = 0
        runningScore = 0
        consecutiveStreak = 0
        gameIsCompleted = false
        stopTimer()
        
        do {
            let fetched = try await HubTriviaService.fetchQuestions()
            questionList = fetched
            if !questionList.isEmpty {
                currentAnswers = questionList[0].allAnswers
                networkState = .active
                startTimer()
            } else {
                networkState = .error
            }
        } catch {
            networkState = .error
        }
    }
    
    func startTimer() {
        timeRemaining = 20
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isAnswerLocked, self.networkState == .active else { return }
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
        consecutiveStreak = 0
        runningScore = max(0, runningScore - 2)
        isAnswerCorrect = false
        
        advanceToNextQuestion(latitude: 0.0, longitude: 0.0)
    }
    
    func submitAnswer(_ answer: String, latitude: Double, longitude: Double) {
        guard !isAnswerLocked else { return }
        stopTimer()
        
        isAnswerLocked = true
        selectedAnswer = answer
        
        let currentQuestion = questionList[currentActiveIndex]
        let isCorrect = (answer == currentQuestion.decodedCorrectAnswer)
        isAnswerCorrect = isCorrect
        
        if isCorrect {
            runningScore += 10
            consecutiveStreak += 1
            if consecutiveStreak >= 3 {
                runningScore += 5
            }
        } else {
            runningScore = max(0, runningScore - 2)
            consecutiveStreak = 0
        }
        
        advanceToNextQuestion(latitude: latitude, longitude: longitude)
    }
    
    private func advanceToNextQuestion(latitude: Double, longitude: Double) {
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            
            selectedAnswer = nil
            isAnswerCorrect = nil
            isAnswerLocked = false
            
            if currentActiveIndex < questionList.count - 1 {
                currentActiveIndex += 1
                currentAnswers = questionList[currentActiveIndex].allAnswers
                startTimer()
            } else {
                saveFinalSession(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    private func saveFinalSession(latitude: Double, longitude: Double) {
        let existingLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
        var list = [GameSession].deserialize(from: existingLedger)
        let playerName = UserDefaults.standard.string(forKey: "currentPlayerName") ?? "Anonymous"
        
        let finalLat = (latitude == 0.0) ? 6.9271 + Double.random(in: -0.005...0.005) : latitude
        let finalLon = (longitude == 0.0) ? 79.8612 + Double.random(in: -0.005...0.005) : longitude
        
        let session = GameSession(
            id: UUID(),
            playerName: playerName,
            mode: .triviaQuiz,
            score: runningScore,
            timestamp: Date(),
            latitude: finalLat,
            longitude: finalLon
        )
        
        list.append(session)
        UserDefaults.standard.set([GameSession].serialize(list), forKey: "hub_ledger")
        
        let currentBest = UserDefaults.standard.integer(forKey: "highScore_quizRush")
        if runningScore > currentBest {
            UserDefaults.standard.set(runningScore, forKey: "highScore_quizRush")
        }
        
        gameIsCompleted = true
    }
}
