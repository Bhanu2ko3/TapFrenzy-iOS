import SwiftUI

class StatsVM: ObservableObject {
    @Published var totalGamesPlayed: Int = 0
    @Published var totalAccumulatedPoints: Int = 0
    
    @Published var tapFrenzyBest: Int = 0
    @Published var lightItUpBest: Int = 0
    @Published var quizRushBest: Int = 0
    
    @Published var gameHistory: [GameSession] = []
    
    func refreshStatistics() {
        let rawLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
        let loadedHistory = [GameSession].deserialize(from: rawLedger)
        gameHistory = loadedHistory.sorted(by: { $0.timestamp > $1.timestamp })
        
        totalGamesPlayed = loadedHistory.count
        totalAccumulatedPoints = loadedHistory.reduce(0) { $0 + $1.score }
        
        tapFrenzyBest = loadedHistory.filter { $0.mode == .frenzySpeed }.map { $0.score }.max() ?? 0
        lightItUpBest = loadedHistory.filter { $0.mode == .gridMatch }.map { $0.score }.max() ?? 0
        quizRushBest = loadedHistory.filter { $0.mode == .triviaQuiz }.map { $0.score }.max() ?? 0
    }
    
    func eraseAllLedgerData() {
        UserDefaults.standard.set("[]", forKey: "hub_ledger")
        UserDefaults.standard.set(0, forKey: "highScore_tapFrenzy")
        UserDefaults.standard.set(0, forKey: "highScore_lightItUp")
        UserDefaults.standard.set(0, forKey: "highScore_quizRush")
        refreshStatistics()
    }
}
