import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyVM()
    @StateObject private var locationService = HubLocationService()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if !viewModel.gameHasStarted {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("Tap Frenzy")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Text("Test your speed! Tap the button as much as you can in 10 seconds. Watch out for penalty colors!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.startNewGame()
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
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            } else if viewModel.gameIsActive {
                VStack(spacing: 30) {
                    HStack {
                        Text("Time: \(viewModel.secondsLeft)s")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Score")
                               .font(.caption)
                               .foregroundColor(.gray)
                            Text("\(viewModel.currentScore)")
                               .font(.system(size: 40, weight: .black, design: .rounded))
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.registerTap()
                    }) {
                        Circle()
                            .fill(viewModel.activeColor)
                            .frame(width: 180, height: 180)
                            .overlay(
                                Text("TAP ME")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: viewModel.activeColor.opacity(0.4), radius: 15, x: 0, y: 10)
                            .scaleEffect(viewModel.isBonusState ? 1.1 : 1.0)
                            .animation(.spring(), value: viewModel.isBonusState)
                    }
                    
                    Spacer()
                    
                    if viewModel.isBonusState {
                        Text("BONUS ACTIVE! +2 POINTS!")
                            .font(.headline)
                            .foregroundColor(.green)
                    } else if viewModel.isPenaltyState {
                        Text("PENALTY ACTIVE! WATCH OUT!")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Tap rapidly!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .onReceive(viewModel.$gameIsActive) { isActive in
                    if !isActive && viewModel.gameHasStarted {
                        viewModel.saveSessionWithLocation(
                            latitude: locationService.latitude,
                            longitude: locationService.longitude
                        )
                    }
                }
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showGameOverScreen) {
            let best = UserDefaults.standard.integer(forKey: "highScore_tapFrenzy")
            ResultView(
                score: viewModel.currentScore,
                highScore: best,
                mode: .frenzySpeed,
                onReset: {
                    viewModel.startNewGame()
                },
                onHome: {
                    viewModel.showGameOverScreen = false
                    dismiss()
                }
            )
        }
    }
}
