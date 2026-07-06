import SwiftUI
import Combine

enum GridLevel {
    case L1, L2, L3, L4
    
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
    
    var litDuration: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
    
    var glowColor: Color {
        switch self {
        case .L1: return .blue
        case .L2: return .orange
        case .L3: return .pink
        case .L4: return .purple
        }
    }
}

struct GridCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

@MainActor
class LightItUpVM: ObservableObject {
    @Published var score: Int = 0
    @Published var timeElapsed: Int = 0
    @Published var isGameActive: Bool = false
    @Published var hasGameStarted: Bool = false
    @Published var showGameOver: Bool = false
    
    @Published var cards: [GridCard] = []
    @Published var currentLevel: GridLevel = .L1
    
    private var gameTimer: AnyCancellable?
    private var secondTimer: AnyCancellable?
    
    func startNewGame() {
        score = 0
        timeElapsed = 0
        isGameActive = true
        hasGameStarted = true
        showGameOver = false
        setupLevel(.L1)
        
        secondTimer?.cancel()
        secondTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.incrementSecond()
            }
    }
    
    private func setupLevel(_ level: GridLevel) {
        currentLevel = level
        cards = (0..<level.cardCount).map { GridCard(id: $0) }
        startGridTimer()
    }
    
    private func startGridTimer() {
        gameTimer?.cancel()
        triggerRandomLightUp()
        
        gameTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.triggerRandomLightUp()
            }
    }
    
    private func triggerRandomLightUp() {
        for index in cards.indices {
            cards[index].isLit = false
        }
        if cards.isEmpty { return }
        
        if currentLevel == .L4 {
            let first = Int.random(in: 0..<cards.count)
            var second = Int.random(in: 0..<cards.count)
            while second == first {
                second = Int.random(in: 0..<cards.count)
            }
            cards[first].isLit = true
            cards[second].isLit = true
        } else {
            let randomIdx = Int.random(in: 0..<cards.count)
            cards[randomIdx].isLit = true
        }
    }
    
    func handleCardTap(_ card: GridCard) {
        guard isGameActive else { return }
        if card.isLit {
            score += 1
            triggerRandomLightUp()
        } else {
            score = max(0, score - 1)
        }
    }
    
    private func incrementSecond() {
        guard isGameActive else { return }
        timeElapsed += 1
        
        if timeElapsed >= 60 {
            endGame()
        } else if timeElapsed >= 45 && currentLevel != .L4 {
            setupLevel(.L4)
        } else if timeElapsed >= 30 && timeElapsed < 45 && currentLevel != .L3 {
            setupLevel(.L3)
        } else if timeElapsed >= 15 && timeElapsed < 30 && currentLevel != .L2 {
            setupLevel(.L2)
        }
    }
    
    private func endGame() {
        isGameActive = false
        gameTimer?.cancel()
        secondTimer?.cancel()
        gameTimer = nil
        secondTimer = nil
    }
    
    func saveSessionWithLocation(latitude: Double, longitude: Double) {
        let existingLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
        var list = [HubGameSession].deserialize(from: existingLedger)
        let playerName = UserDefaults.standard.string(forKey: "currentPlayerName") ?? "Anonymous"
        
        let session = HubGameSession(
            id: UUID(),
            playerName: playerName,
            mode: .gridMatch,
            finalScore: score,
            playedAt: Date(),
            locLatitude: latitude,
            locLongitude: longitude
        )
        
        list.append(session)
        UserDefaults.standard.set([HubGameSession].serialize(list), forKey: "hub_ledger")
        
        let currentBest = UserDefaults.standard.integer(forKey: "highScore_lightItUp")
        if score > currentBest {
            UserDefaults.standard.set(score, forKey: "highScore_lightItUp")
        }
        
        showGameOver = true
        hasGameStarted = false
    }
}
