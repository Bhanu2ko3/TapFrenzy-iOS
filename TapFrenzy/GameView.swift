
import SwiftUI

struct GameView: View {
    @Binding var score: Int
    @Binding var timeRemaining: Int
    @Binding var isGameActive: Bool
    
    // Challenge bindings passed from main state
    @Binding var buttonColor: Color
    @Binding var isBonusActive: Bool
    @Binding var isPenaltyActive: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Header Section: Title and Live Countdown Display
            VStack(spacing: 10) {
                Text("Tap Frenzy! 🎮")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Time Remaining: \(timeRemaining)s")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(timeRemaining > 3 ? .red : .orange)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Score Display Section: Tracks live score updates
            VStack {
                Text("Score")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(score)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            // Challenge 2 Indicator Text Hints
            if isBonusActive {
                Text("💥 BONUS ACTIVE! (+2 Points) 💥")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            } else if isPenaltyActive {
                Text("⚠️ PENALTY RISK! (-1 Point) ⚠️")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            } else {
                Text("Normal Mode (+1 Point)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Interaction Section: Main Core Gameplay TAP Button Container
            VStack {
                Button(action: {
                    if isGameActive {
                        // Challenge 2 Action Logic
                        if isBonusActive {
                            score += 2
                        } else if isPenaltyActive {
                            if score > 0 { score -= 1 } // Prevent negative scores
                        } else {
                            score += 1
                        }
                    }
                }) {
                    Text(isBonusActive ? "BONUS!" : (isPenaltyActive ? "CAREFUL!" : "TAP ME!"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        // Challenge 4 Logic: Shrink width/height dynamic padding based on seconds left
                        .frame(
                            width: CGFloat(130 + (timeRemaining * 7)),
                            height: CGFloat(130 + (timeRemaining * 7))
                        )
                        .background(buttonColor)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .animation(.easeInOut, value: timeRemaining)
                }
            }
            // Fixed height container to prevent layout shifting when the button shrinks
            .frame(height: 220)
            .padding(.bottom, 50)
        }
    }
}
