import SwiftUI

struct GameView: View {
    @Binding var score: Int
    @Binding var timeRemaining: Int
    @Binding var isGameActive: Bool
    
    // Challenge bindings passed from main state
    @Binding var buttonColor: Color
    @Binding var isBonusActive: Bool
    @Binding var isPenaltyActive: Bool
    
    // Random offsets for moving button
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Header Section: Title and Live Countdown Display
            VStack(spacing: 10) {
                Text("Tap Frenzy")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.blue)
                
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
                    .font(.system(size: 100, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Challenge 2 Indicator Text Hints
            if isBonusActive {
                Text("BONUS ACTIVE! (+2 Points)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            } else if isPenaltyActive {
                Text("PENALTY RISK! (-1 Point)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            } else {
                Text("Normal Mode (+1 Point)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Interaction Section: Main Core Gameplay TAP Button Container
            ZStack {
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
                    Text(isBonusActive ? "BONUS" : (isPenaltyActive ? "CAREFUL" : "TAP"))
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
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: score)
                        .animation(.easeInOut, value: timeRemaining)
                }
                .offset(x: offsetX, y: offsetY)
                .animation(.easeInOut(duration: 0.4), value: offsetX)
                .animation(.easeInOut(duration: 0.4), value: offsetY)
            }
            // Larger container so the button has room to move without clipping
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .padding(.bottom, 30)
        }
        .onChange(of: timeRemaining) { _ in
            if isGameActive {
                // Randomize position every second within safe bounds
                offsetX = CGFloat.random(in: -100...100)
                offsetY = CGFloat.random(in: -80...80)
            } else {
                offsetX = 0
                offsetY = 0
            }
        }
    }
}
