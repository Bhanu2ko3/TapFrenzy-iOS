import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizEngineVM()
    @StateObject private var locationService = HubLocationService()
    @Environment(\.dismiss) var dismiss
    
    @State private var gameInitiated = false
    
    var topScores: [HubGameSession] {
        let rawLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
        let allSessions = [HubGameSession].deserialize(from: rawLedger)
        let modeSessions = allSessions.filter { $0.mode == .triviaQuiz }
        
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
            if !gameInitiated {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.indigo)
                        
                        Text("Quiz Rush")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.indigo)
                    }
                    
                    Text("Test your general knowledge! Answer 10 trivia questions. Faster answers keep your streak alive!")
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
                                          .foregroundColor(.indigo)
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
                        gameInitiated = true
                        Task {
                            await viewModel.loadGame()
                        }
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
                        .background(Color.indigo)
                        .cornerRadius(15)
                        .shadow(color: .indigo.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            } else {
                switch viewModel.networkState {
                case .loading:
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2)
                        
                        Text("Fetching Live Questions...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                case .error:
                    VStack(spacing: 20) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("Connection Failed")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            Task {
                                await viewModel.loadGame()
                            }
                        }) {
                            Text("Retry")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                case .active:
                    VStack(spacing: 25) {
                        HStack {
                            Text("Question \(viewModel.currentActiveIndex + 1) of 10")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(viewModel.consecutiveStreak >= 3 ? .orange : .gray)
                                
                                Text("Streak: \(viewModel.consecutiveStreak)")
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.consecutiveStreak >= 3 ? .orange : .gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("Score: \(viewModel.runningScore)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.indigo)
                        
                        VStack(spacing: 8) {
                            ProgressView(value: Double(viewModel.timeRemaining), total: 20.0)
                                .tint(.indigo)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .foregroundColor(.indigo)
                                Text("\(viewModel.timeRemaining)s")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.indigo)
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.currentActiveIndex < viewModel.questionList.count {
                            let currentQuestion = viewModel.questionList[viewModel.currentActiveIndex]
                            
                            VStack(spacing: 15) {
                                Text(currentQuestion.decodedQuestion)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                            
                            Spacer()
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.currentAnswers, id: \.self) { answer in
                                    Button(action: {
                                        viewModel.submitAnswer(
                                            answer,
                                            latitude: locationService.latitude,
                                            longitude: locationService.longitude
                                        )
                                    }) {
                                        Text(answer)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding()
                                            .frame(maxWidth: .infinity, minHeight: 50)
                                            .background(buttonColor(for: answer, in: currentQuestion))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.indigo.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .disabled(viewModel.isAnswerLocked)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationTitle("Quiz Rush")
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
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.indigo.opacity(0.15))
                    .cornerRadius(20)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.gameIsCompleted) {
            let best = UserDefaults.standard.integer(forKey: "highScore_quizRush")
            ResultView(
                score: viewModel.runningScore,
                highScore: best,
                mode: .triviaQuiz,
                onReset: {
                    viewModel.gameIsCompleted = false
                    gameInitiated = true
                    Task {
                        await viewModel.loadGame()
                    }
                },
                onHome: {
                    viewModel.gameIsCompleted = false
                    dismiss()
                }
            )
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
    
    private func buttonColor(for answer: String, in question: TriviaQuestion) -> Color {
        if viewModel.isAnswerLocked {
            if answer == question.decodedCorrectAnswer {
                return .green.opacity(0.3)
            }
            if viewModel.selectedAnswer == answer {
                return .red.opacity(0.3)
            }
        }
        return Color(.systemBackground)
    }
}
