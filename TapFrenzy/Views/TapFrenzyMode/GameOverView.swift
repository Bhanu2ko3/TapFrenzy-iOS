import SwiftUI

struct GameOverView: View {
    @Binding var score: Int
    @Binding var timeRemaining: Int
    @Binding var isGameActive: Bool
    @Binding var hasGameStarted: Bool // Binding to control transition back to home screen
    @Binding var highScore: Int
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Image(systemName: "flag.checkered")
                Text("GAME OVER")
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(.red)
            .padding(.top, 50)
            
            Spacer()
            
            // Performance Results Section
            VStack(spacing: 15) {
                Text("Your Final Score")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("\(score)")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Crown High Score Indicator Display
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("High Score: \(highScore)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.top, 10)
                
                if score >= highScore && score > 0 {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("New Personal Best!")
                        Image(systemName: "star.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top, 5)
                }
            }
            
            Spacer()
            
            // Control Action Section: Return to Start Menu Option
            Button(action: {
                // Reset states and take user back to the Start Menu
                withAnimation {
                    score = 0
                    timeRemaining = 10
                    isGameActive = true
                    hasGameStarted = false
                }
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
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
