import SwiftUI

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpVM()
    @StateObject private var locationService = HubLocationService()
    @Environment(\.dismiss) var dismiss
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
    }
    
    var body: some View {
        VStack {
            if !viewModel.hasGameStarted {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "square.grid.3x3.topleft.filled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.purple)
                        
                        Text("Light It Up")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.purple)
                    }
                    
                    Text("Whack-a-Mole style challenge! Tap the glowing cards before they shift. The grid grows and speed increases every 15 seconds!")
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
                        .background(Color.purple)
                        .cornerRadius(15)
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            } else if viewModel.isGameActive {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Time: \(60 - viewModel.timeElapsed)s")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Level: \(String(describing: viewModel.currentLevel))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.currentLevel.glowColor)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Score")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("\(viewModel.score)")
                                .font(.system(size: 45, weight: .black, design: .rounded))
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(viewModel.cards) { card in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(card.isLit ? viewModel.currentLevel.glowColor : Color(.systemGray5))
                                .frame(height: viewModel.currentLevel == .L3 || viewModel.currentLevel == .L4 ? 95 : 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(card.isLit ? viewModel.currentLevel.glowColor : Color.clear, lineWidth: 4)
                                        .shadow(color: card.isLit ? viewModel.currentLevel.glowColor : .clear, radius: 10)
                                )
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .onTapGesture {
                                    viewModel.handleCardTap(card)
                                }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: viewModel.currentLevel == .L4 ? "flame.fill" : "bolt.fill")
                        Text(viewModel.currentLevel == .L4 ? "DOUBLE TROUBLE! 2 CARDS LIT!" : "Tap the colored card quickly!")
                    }
                    .font(.subheadline)
                    .foregroundColor(viewModel.currentLevel == .L4 ? .red : .gray)
                }
                .padding()
                .onReceive(viewModel.$isGameActive) { isActive in
                    if !isActive && viewModel.hasGameStarted {
                        viewModel.saveSessionWithLocation(
                            latitude: locationService.latitude,
                            longitude: locationService.longitude
                        )
                    }
                }
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showGameOver) {
            let best = UserDefaults.standard.integer(forKey: "highScore_lightItUp")
            ResultView(
                score: viewModel.score,
                highScore: best,
                mode: .gridMatch,
                onReset: {
                    viewModel.startNewGame()
                },
                onHome: {
                    viewModel.showGameOver = false
                    dismiss()
                }
            )
        }
    }
}
