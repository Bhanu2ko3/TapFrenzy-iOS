
import SwiftUI

struct ContentView: View {
    // MARK: - Game State Properties
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = true
    @State private var hasGameStarted = false // Challenge Architecture: Track if start button was clicked
    
    // PERSISTENCE CHALLENGE: Replaced @State with @AppStorage to persist score across app restarts
    @AppStorage("highScore_tapFrenzy") private var highScore = 0
    
    // MARK: - Challenge 2 Properties: Color Changer States
    @State private var buttonColor = Color.blue
    @State private var isBonusActive = false
    @State private var isPenaltyActive = false
    
    // MARK: - Countdown Timer Publisher
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if !hasGameStarted {
                // 1. Initial Start Screen View Menu Component
                VStack(spacing: 40) {
                    Text("Tap Frenzy! 🎮")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.top, 60)
                    
                    Text("Test your speed! Tap the button as much as you can in 10 seconds. Watch out for penalty colors!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // High Score Badge Tracker Display
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
                        hasGameStarted = true // Launch game and start timer loop
                    }) {
                        Text("START GAME 🚀")
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
                    .padding(.bottom, 80)
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
                    highScore: $highScore // Linked smoothly to @AppStorage
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
            } else {
                // Finalize state limits once ticks reach absolute zero bounds
                isGameActive = false
                if score > highScore {
                    highScore = score // Automatically saves directly to device storage!
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
