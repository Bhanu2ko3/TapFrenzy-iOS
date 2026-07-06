import SwiftUI
import Combine

@MainActor
class TapFrenzyVM: ObservableObject {
    @Published var currentScore: Int = 0
    @Published var secondsLeft: Int = 10
    @Published var gameIsActive: Bool = false
    @Published var gameHasStarted: Bool = false
    @Published var showGameOverScreen: Bool = false
    
    @Published var activeColor: Color = .blue
    @Published var isBonusState: Bool = false
    @Published var isPenaltyState: Bool = false
    
    private var ticker: AnyCancellable?
    
    func startNewGame() {
        currentScore = 0
        secondsLeft = 10
        gameIsActive = true
        gameHasStarted = true
        showGameOverScreen = false
        activeColor = .blue
        isBonusState = false
        isPenaltyState = false
        
        ticker?.cancel()
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tick()
            }
    }
    
    private func tick() {
        guard gameIsActive else { return }
        if secondsLeft > 0 {
            secondsLeft -= 1
            if secondsLeft % 2 == 0 {
                let roll = Int.random(in: 1...3)
                if roll == 1 {
                    activeColor = .green
                    isBonusState = true
                    isPenaltyState = false
                } else if roll == 2 {
                    activeColor = .gray
                    isBonusState = false
                    isPenaltyState = true
                } else {
                    activeColor = .blue
                    isBonusState = false
                    isPenaltyState = false
                }
            }
        } else {
            gameIsActive = false
            ticker?.cancel()
            ticker = nil
        }
    }
    
    func registerTap() {
        guard gameIsActive else { return }
        if isBonusState {
            currentScore += 2
        } else if isPenaltyState {
            currentScore = max(0, currentScore - 2)
        } else {
            currentScore += 1
        }
    }
    
    func saveSessionWithLocation(latitude: Double, longitude: Double) {
        let existingLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
        var list = [HubGameSession].deserialize(from: existingLedger)
        
        let session = HubGameSession(
            id: UUID(),
            mode: .frenzySpeed,
            finalScore: currentScore,
            playedAt: Date(),
            locLatitude: latitude,
            locLongitude: longitude
        )
        
        list.append(session)
        UserDefaults.standard.set([HubGameSession].serialize(list), forKey: "hub_ledger")
        
        let currentBest = UserDefaults.standard.integer(forKey: "highScore_tapFrenzy")
        if currentScore > currentBest {
            UserDefaults.standard.set(currentScore, forKey: "highScore_tapFrenzy")
        }
        
        showGameOverScreen = true
    }
}
