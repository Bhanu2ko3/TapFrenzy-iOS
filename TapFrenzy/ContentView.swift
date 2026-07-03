import SwiftUI

struct ContentView: View {
    // MARK: - Persisted Data
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("game_history") private var historyJSON: String = "[]"
    @AppStorage("highScore_tapFrenzy") private var highScore = 0
    
    // MARK: - Game State Properties
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = true
    @State private var hasGameStarted = false
    
    // MARK: - Challenge 2 Properties: Color Changer States
    @State private var buttonColor = Color.blue
    @State private var isBonusActive = false
    @State private var isPenaltyActive = false
    
    // MARK: - Countdown Timer Publisher
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Computed Leaderboard: Unique highest score per player
    var topPlayers: [RoundResult] {
        let allResults = RoundResult.load(from: historyJSON)
        let modeResults = allResults.filter { $0.gameMode == "Tap Frenzy" }
        
        var highestScores: [String: RoundResult] = [:]
        for result in modeResults {
            if let existing = highestScores[result.playerName] {
                if result.score > existing.score {
                    highestScores[result.playerName] = result
                }
            } else {
                highestScores[result.playerName] = result
            }
        }
        
        return Array(highestScores.values.sorted(by: { $0.score > $1.score }).prefix(3))
    }
    
    var body: some View {
        VStack {
            if !hasGameStarted {
                // 1. Initial Start Screen
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Tap Frenzy")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 40)
                    
                    Text("Test your speed! Tap the button as much as you can in 10 seconds. Watch out for penalty colors!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Leaderboard Section
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "list.star")
                                .foregroundColor(.yellow)
                            Text("Top Players")
                                .font(.headline)
                        }
                        
                        if topPlayers.isEmpty {
                            Text("No scores yet. Be the first!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(Array(topPlayers.enumerated()), id: \.element.id) { index, result in
                                HStack {
                                    Text("\(index + 1).")
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    Text(result.playerName)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(result.score)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Main Start Core Interface Trigger Button
                    Button(action: {
                        withAnimation {
                            hasGameStarted = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("START GAME")
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            } else if isGameActive {
                // 2. Extracted Subview Component for Active Gameplay
                GameView(
                    score: $score,
                    timeRemaining: $timeRemaining,
                    isGameActive: $isGameActive,
                    buttonColor: $buttonColor,
                    isBonusActive: $isBonusActive,
                    isPenaltyActive: $isPenaltyActive
                )
            } else {
                // 3. Extracted Subview Component for End Results Summary View
                GameOverView(
                    score: $score,
                    timeRemaining: $timeRemaining,
                    isGameActive: $isGameActive,
                    hasGameStarted: $hasGameStarted,
                    highScore: $highScore
                )
            }
        }
        .padding()
        // MARK: - Core Timer Publisher Engine Listener
        .onReceive(timer) { _ in
            // Only execute countdown loops if the active gameplay sequence has initiated
            guard hasGameStarted && isGameActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                // Challenge 2 Processing: Update color values at modulo interval steps
                if timeRemaining % 2 == 0 {
                    let randomState = Int.random(in: 1...3)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if randomState == 1 {
                            buttonColor = Color.green
                            isBonusActive = true
                            isPenaltyActive = false
                        } else if randomState == 2 {
                            buttonColor = Color.gray
                            isBonusActive = false
                            isPenaltyActive = true
                        } else {
                            buttonColor = Color.blue
                            isBonusActive = false
                            isPenaltyActive = false
                        }
                    }
                }
            } else {
                // Finalize state limits once ticks reach absolute zero bounds
                isGameActive = false
                if score > highScore {
                    highScore = score // Automatically saves directly to device storage!
                }
                
                // Save to History
                let result = RoundResult(playerName: playerName.isEmpty ? "Anonymous" : playerName,
                                         gameMode: "Tap Frenzy",
                                         score: score,
                                         date: Date())
                var currentHistory = RoundResult.load(from: historyJSON)
                currentHistory.append(result)
                historyJSON = RoundResult.save(currentHistory)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
