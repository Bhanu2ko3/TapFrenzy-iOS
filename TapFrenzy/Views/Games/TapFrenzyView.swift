import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyVM()
    @StateObject private var locationService = HubLocationService()
    @Environment(\.dismiss) var dismiss
    
    @State private var buttonOffsetX: CGFloat = 0.0
    @State private var buttonOffsetY: CGFloat = 0.0
    
    var buttonSize: CGFloat {
        80.0 + CGFloat(viewModel.secondsLeft) * 10.0
    }
    
    var buttonFont: Font {
        if viewModel.secondsLeft <= 4 {
            return .body
        } else if viewModel.secondsLeft <= 7 {
            return .headline
        } else {
            return .title
        }
    }
    
    var topScores: [HubGameSession] {
        let rawLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
        let allSessions = [HubGameSession].deserialize(from: rawLedger)
        let modeSessions = allSessions.filter { $0.mode == .frenzySpeed }
        
        var uniqueBests: [String: HubGameSession] = [:]
        for session in modeSessions {
            if let existing = uniqueBests[session.playerName] {
                if session.finalScore > existing.finalScore {
                    uniqueBests[session.playerName] = session
                }
            } else {
                uniqueBests[session.playerName] = session
            }
        }
        return Array(uniqueBests.values.sorted(by: { $0.finalScore > $1.finalScore }).prefix(3))
    }
    
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
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "list.star")
                                .foregroundColor(.yellow)
                            Text("Top Players")
                                .font(.headline)
                        }
                        
                        if topScores.isEmpty {
                            Text("No scores yet. Be the first!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(Array(topScores.enumerated()), id: \.element.id) { index, result in
                                HStack {
                                    Text("\(index + 1).")
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    Text(result.playerName)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(result.finalScore)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        buttonOffsetX = 0
                        buttonOffsetY = 0
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
                        buttonOffsetX = CGFloat.random(in: -80...80)
                        buttonOffsetY = CGFloat.random(in: -120...120)
                    }) {
                        Circle()
                            .fill(viewModel.activeColor)
                            .frame(width: buttonSize, height: buttonSize)
                            .overlay(
                                Text("TAP ME")
                                    .font(buttonFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: viewModel.activeColor.opacity(0.4), radius: 15, x: 0, y: 10)
                            .offset(x: buttonOffsetX, y: buttonOffsetY)
                            .animation(.spring(), value: buttonOffsetX)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title3)
                        Text("Home")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(20)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showGameOverScreen) {
            let best = UserDefaults.standard.integer(forKey: "highScore_tapFrenzy")
            ResultView(
                score: viewModel.currentScore,
                highScore: best,
                mode: .frenzySpeed,
                onReset: {
                    buttonOffsetX = 0
                    buttonOffsetY = 0
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
