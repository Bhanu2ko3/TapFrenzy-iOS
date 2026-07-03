import SwiftUI

struct QuizGameOverView: View {
    let score: Int
    let streak: Int
    
    // Callbacks for navigation
    var onPlayAgain: () -> Void
    var onHome: () -> Void
    
    // Global persistence
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("game_history") private var historyJSON: String = "[]"
    @AppStorage("highScore_quizRush") private var highScore = 0
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Image(systemName: "flag.checkered")
                Text("QUIZ FINISHED")
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(.indigo)
            .padding(.top, 50)
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Your Final Score")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("\(score)")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                HStack(spacing: 20) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("High Score: \(max(score, highScore))")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Top Streak: \(streak)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 10)
                
                if score > highScore && score > 0 {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("New Knowledge Master!")
                        Image(systemName: "star.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .padding(.top, 5)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    saveScore()
                    onPlayAgain()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
                Button(action: {
                    saveScore()
                    onHome()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Return Home")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .padding()
        .onAppear {
            if score > highScore {
                highScore = score
            }
        }
    }
    
    private func saveScore() {
        let result = RoundResult(
            playerName: playerName.isEmpty ? "Anonymous" : playerName,
            gameMode: "Quiz Rush",
            score: score,
            date: Date()
        )
        
        var currentHistory = RoundResult.load(from: historyJSON)
        currentHistory.append(result)
        historyJSON = RoundResult.save(currentHistory)
    }
}
