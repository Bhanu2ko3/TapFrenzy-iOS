
import SwiftUI

// MARK: - Game Level Architecture Enum
enum GameLevel {
    case L1, L2, L3, L4
    
    var cardCount: Int {
        switch self {
        case .L1: return 3   // 3 cards in a row [cite: 31, 40]
        case .L2: return 4   // 4 cards grid [cite: 32, 41]
        case .L3: return 6   // 6 cards (2x3) [cite: 35, 38, 42]
        case .L4: return 9   // 9 cards (3x3) [cite: 37, 39, 43]
        }
    }
    
    var litDuration: Double {
        switch self {
        case .L1: return 1.5  // 1.5 seconds [cite: 40]
        case .L2: return 1.2  // 1.2 seconds [cite: 41]
        case .L3: return 1.0  // 1.0 seconds [cite: 42]
        case .L4: return 0.8  // 0.8 seconds [cite: 43]
        }
    }
}

struct GameCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

struct LightItUpGameView: View {
    // MARK: - AppStorage Persistence
    @AppStorage("highScore_lightItUp") private var highScore = 0 // [cite: 25, 74]
    
    // MARK: - Game States
    @State private var score = 0
    @State private var timeElapsed = 0 // Tracks time from 0 up to 60 seconds [cite: 19, 27]
    @State private var isGameActive = true
    @State private var cards: [GameCard] = []
    @State private var currentLevel: GameLevel = .L1
    
    // Core game timing engines
    @State private var gameTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    let secondsTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Dynamic column layout configuration [cite: 52]
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // HUD Information Banner
            HStack {
                VStack(alignment: .leading) {
                    Text("Time: \(60 - timeElapsed)s") // 60s countdown [cite: 19, 27]
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Level: \(String(describing: currentLevel))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Score: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Best: \(highScore)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // DYNAMIC GRID CHALLENGE: Grid reshapes based on difficulty levels [cite: 7, 19, 52]
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(card.isLit ? Color.purple : Color(.systemGray5)) // [cite: 52, 76]
                        .frame(height: currentLevel == .L3 || currentLevel == .L4 ? 95 : 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(card.isLit ? Color.purple : Color.clear, lineWidth: 4)
                                .shadow(color: card.isLit ? .purple : .clear, radius: 10)
                        )
                        .scaleEffect(card.isLit ? 1.05 : 1.0) // [cite: 52]
                        .animation(.spring(), value: card.isLit) // [cite: 52]
                        .onTapGesture {
                            handleCardTap(clickedCard: card) // [cite: 53]
                        }
                }
            }
            .padding()
            
            Spacer()
            
            Text(currentLevel == .L4 ? "🔥 DOUBLE TROUBLE! 2 CARDS LIT! 🔥" : "Tap the purple card quickly! ⚡")
                .font(.subheadline)
                .fontWeight(currentLevel == .L4 ? .bold : .regular)
                .foregroundColor(currentLevel == .L4 ? .red : .gray)
        }
        .padding()
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupLevel(level: .L1)
        }
        // WHACK-A-MOLE LOOP: Regenerates lit states based on variable level intervals [cite: 11, 63, 64]
        .onReceive(gameTimer) { _ in
            guard isGameActive else { return }
            triggerRandomLightUp()
        }
        // STEP LEVEL PROGRESSION LOOP: Shifts level scales every 15 ticks interval steps [cite: 19, 27, 66]
        .onReceive(secondsTimer) { _ in
            guard isGameActive else { return }
            
            timeElapsed += 1
            
            // Check for level progression phases [cite: 19, 27, 66]
            if timeElapsed >= 60 {
                endGame()
            } else if timeElapsed >= 45 && currentLevel != .L4 {
                setupLevel(level: .L4) // 45-60 seconds -> Level 4 [cite: 36, 37]
            } else if timeElapsed >= 30 && timeElapsed < 45 && currentLevel != .L3 {
                setupLevel(level: .L3) // 30-45 seconds -> Level 3 [cite: 34, 35]
            } else if timeElapsed >= 15 && timeElapsed < 30 && currentLevel != .L2 {
                setupLevel(level: .L2) // 15-30 seconds -> Level 2 [cite: 30, 33]
            }
        }
    }
    
    // MARK: - Game Control Logics
    private func setupLevel(level: GameLevel) {
        currentLevel = level
        
        // Setup raw cards capacity mapped to level requirement arrays [cite: 62]
        cards = (0..<level.cardCount).map { GameCard(id: $0) }
        
        // Re-align game publisher loop engine interval parameters dynamically [cite: 64]
        self.gameTimer = Timer.publish(every: level.litDuration, on: .main, in: .common).autoconnect()
        
        triggerRandomLightUp()
    }
    
    private func triggerRandomLightUp() {
        for index in cards.indices {
            cards[index].isLit = false
        }
        
        // Level 4 Special: Light up 2 random cards simultaneously [cite: 43]
        if currentLevel == .L4 {
            let firstRandom = Int.random(in: 0..<cards.count)
            var secondRandom = Int.random(in: 0..<cards.count)
            
            while secondRandom == firstRandom {
                secondRandom = Int.random(in: 0..<cards.count)
            }
            
            cards[firstRandom].isLit = true
            cards[secondRandom].isLit = true
        } else {
            // Standard Levels: Light up exactly 1 random card item [cite: 6, 16]
            let randomIndex = Int.random(in: 0..<cards.count)
            cards[randomIndex].isLit = true
        }
    }
    
    private func handleCardTap(clickedCard: GameCard) {
        guard isGameActive else { return }
        
        if clickedCard.isLit {
            score += 1 // Correct tap [cite: 54, 72]
            triggerRandomLightUp()
        } else {
            if score > 0 { score -= 1 } // Wrong tap penalty [cite: 54, 72]
        }
    }
    
    private func endGame() {
        isGameActive = false
        if score > highScore {
            highScore = score // [cite: 67]
        }
    }
}
