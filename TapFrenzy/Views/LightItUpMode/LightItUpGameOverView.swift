import SwiftUI

struct LightItUpGameOverView: View {
    let score: Int
    @Binding var isGameActive: Bool
    @Binding var timeElapsed: Int
    @Binding var showGameOver: Bool
    
    var onReset: () -> Void // Callback block function execution handler routine
    var onHome: () -> Void // Added for Return Home functionality
    
    @AppStorage("highScore_lightItUp") private var highScore = 0
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Image(systemName: "flag.checkered")
                Text("ROUND FINISHED")
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(.purple)
            .padding(.top, 60)
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Your Final Score")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("\(score)")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
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
                        Text("New Grid Master Record!")
                        Image(systemName: "star.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.purple)
                    .padding(.top, 5)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    // Reset parent tracking elements to initial configurations bounds
                    withAnimation {
                        timeElapsed = 0
                        isGameActive = true
                        showGameOver = false
                        onReset() // Trigger parent refresh closure blocks
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
                    .background(Color.purple)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
                Button(action: {
                    withAnimation {
                        onHome()
                    }
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Return Home")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .padding()
    }
}
