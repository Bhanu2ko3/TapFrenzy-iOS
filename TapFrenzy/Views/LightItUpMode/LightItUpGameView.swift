
import SwiftUI

enum GameLevel {
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
        case .L1: return Color.blue
        case .L2: return Color.orange
        case .L3: return Color.pink
        case .L4: return Color.purple
        }
    }
}

struct GameCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

struct LightItUpGameView: View {
    @AppStorage("highScore_lightItUp") private var highScore = 0
    
    // MARK: - Game States
    @State private var score = 0
    @State private var timeElapsed = 0
    @State private var isGameActive = true
    @State private var hasGameStarted = false // Tracks if user clicked START GAME
    @State private var cards: [GameCard] = []
    @State private var currentLevel: GameLevel = .L1
    @State private var showGameOver = false
    
    @State private var gameTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    let secondsTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
    }
    
    var body: some View {
        VStack {
            if !hasGameStarted {
                // MARK: - 1. Initial Start Screen Menu Component
                VStack(spacing: 35) {
                    Text("Light It Up! ⏱️")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.purple)
                        .padding(.top, 40)
                    
                    Text("Whack-a-Mole style challenge! Tap the glowing cards before they shift. The grid grows and speed increases every 15 seconds!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // High Score Badge Display
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Current High Score: \(highScore)")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Main Start Core Interface Trigger Button
                    Button(action: {
                        hasGameStarted = true // Launch game loop active sequence
                        setupLevel(level: .L1)
                    }) {
                        Text("START GAME 🚀")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            } else {
                // MARK: - 2. Active Gameplay Grid Screen Component
                VStack(spacing: 20) {
                    HStack {
                        // HUD Info
                        VStack(alignment: .leading) {
                            Text("Time: \(60 - timeElapsed)s")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Level: \(String(describing: currentLevel))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(currentLevel.glowColor)
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
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(cards) { card in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(card.isLit ? currentLevel.glowColor : Color(.systemGray5))
                                .frame(height: currentLevel == .L3 || currentLevel == .L4 ? 95 : 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(card.isLit ? currentLevel.glowColor : Color.clear, lineWidth: 4)
                                        .shadow(color: card.isLit ? currentLevel.glowColor : .clear, radius: 10)
                                )
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .animation(.spring(), value: card.isLit)
                                .onTapGesture {
                                    handleCardTap(clickedCard: card)
                                }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text(currentLevel == .L4 ? "🔥 DOUBLE TROUBLE! 2 CARDS LIT! 🔥" : "Tap the colored card quickly! ⚡")
                        .font(.subheadline)
                        .fontWeight(currentLevel == .L4 ? .bold : .regular)
                        .foregroundColor(currentLevel == .L4 ? .red : .gray)
                }
            }
        }
        .padding()
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showGameOver) {
            LightItUpGameOverView(score: score, isGameActive: $isGameActive, timeElapsed: $timeElapsed, showGameOver: $showGameOver, onReset: {
                // Re-initialize all states on reset action trigger
                score = 0
                setupLevel(level: .L1)
            })
        }
        .onReceive(gameTimer) { _ in
            guard hasGameStarted && isGameActive else { return }
            triggerRandomLightUp()
        }
        .onReceive(secondsTimer) { _ in
            guard hasGameStarted && isGameActive else { return }
            
            timeElapsed += 1
            
            if timeElapsed >= 60 {
                endGame()
            } else if timeElapsed >= 45 && currentLevel != .L4 {
                setupLevel(level: .L4)
            } else if timeElapsed >= 30 && timeElapsed < 45 && currentLevel != .L3 {
                setupLevel(level: .L3)
            } else if timeElapsed >= 15 && timeElapsed < 30 && currentLevel != .L2 {
                setupLevel(level: .L2)
            }
        }
    }
    
    private func setupLevel(level: GameLevel) {
        currentLevel = level
        cards = (0..<level.cardCount).map { GameCard(id: $0) }
        self.gameTimer = Timer.publish(every: level.litDuration, on: .main, in: .common).autoconnect()
        triggerRandomLightUp()
    }
    
    private func triggerRandomLightUp() {
        for index in cards.indices {
            cards[index].isLit = false
        }
        
        if currentLevel == .L4 {
            let firstRandom = Int.random(in: 0..<cards.count)
            var secondRandom = Int.random(in: 0..<cards.count)
            while secondRandom == firstRandom {
                secondRandom = Int.random(in: 0..<cards.count)
            }
            cards[firstRandom].isLit = true
            cards[secondRandom].isLit = true
        } else {
            let randomIndex = Int.random(in: 0..<cards.count)
            cards[randomIndex].isLit = true
        }
    }
    
    private func handleCardTap(clickedCard: GameCard) {
        guard isGameActive else { return }
        
        if clickedCard.isLit {
            score += 1
            triggerRandomLightUp()
        } else {
            if score > 0 { score -= 1 }
        }
    }
    
    private func endGame() {
        isGameActive = false
        if score > highScore {
            highScore = score
        }
        showGameOver = true
        hasGameStarted = false // Reset state so that restarting goes back to menu
    }
}
