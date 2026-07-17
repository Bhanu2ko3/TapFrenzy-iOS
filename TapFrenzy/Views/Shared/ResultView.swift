import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let mode: GameMode
    let onReset: () -> Void
    let onHome: () -> Void
    
    var modeTitle: String {
        switch mode {
        case .frenzySpeed: return "Tap Frenzy"
        case .gridMatch: return "Light It Up"
        case .triviaQuiz: return "Quiz Rush"
        }
    }
    
    var shareMessage: String {
        return "I just scored \(score) on \(modeTitle) — beat that!"
    }
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Image(systemName: "flag.checkered")
                Text("GAME OVER")
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(.red)
            .padding(.top, 40)
            
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
                        Text("New Personal Best!")
                        Image(systemName: "star.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top, 5)
                }
            }
            
            Spacer()
            
            ShareLink(item: shareMessage) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill")
                    Text("Share Your Score")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                Button(action: onReset) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
                    .shadow(color: .green.opacity(0.2), radius: 5)
                }
                
                Button(action: onHome) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Return Home")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}
