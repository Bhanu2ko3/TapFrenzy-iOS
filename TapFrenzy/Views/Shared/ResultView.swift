import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let mode: AppGameMode
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
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 15) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.4), radius: 10)
                
                Text("Game Over")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(modeTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    VStack {
                        Text("Your Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(score)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                    
                    VStack {
                        Text("Best Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(highScore)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                }
            }
            .padding(.horizontal, 30)
            
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
            .padding(.horizontal, 30)
            
            VStack(spacing: 15) {
                Button(action: onReset) {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(15)
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: onHome) {
                    Text("Return Home")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}
