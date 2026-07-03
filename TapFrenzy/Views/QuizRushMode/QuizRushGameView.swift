import SwiftUI

struct QuizRushGameView: View {
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2)
                    Text("Fetching Live Questions...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
            case .failed:
                VStack(spacing: 20) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Connection Failed")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Could not fetch questions from the server.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        Task { await viewModel.loadGame() }
                    }) {
                        Text("Retry")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                
            case .loaded:
                loadedView
                
            case .completed:
                QuizGameOverView(score: viewModel.score, streak: viewModel.longestStreak) {
                    Task { await viewModel.loadGame() }
                } onHome: {
                    dismiss()
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Load game immediately when view appears
            await viewModel.loadGame()
        }
    }
    
    // Extracted view for the loaded state to keep body clean
    private var loadedView: some View {
        VStack(spacing: 30) {
            // Header: Progress and Streak
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of 10")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(viewModel.streak >= 3 ? .orange : .gray)
                    Text("Streak: \(viewModel.streak)")
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.streak >= 3 ? .orange : .gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Score Display
            Text("Score: \(viewModel.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Spacer()
            
            // Question Display
            let currentQuestion = viewModel.questions[viewModel.currentIndex]
            
            Text(currentQuestion.decodedQuestion)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                .animation(.easeInOut, value: viewModel.currentIndex)
            
            Spacer()
            
            // Answers Grid
            VStack(spacing: 15) {
                ForEach(currentQuestion.allAnswers, id: \.self) { answer in
                    Button(action: {
                        viewModel.submitAnswer(answer)
                    }) {
                        Text(answer)
                            .font(.headline)
                            .foregroundColor(buttonTextColor(for: answer))
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(buttonBackgroundColor(for: answer))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(viewModel.isAnswerLocked)
                    // Apply a shake offset if this was the selected wrong answer
                    .offset(x: (viewModel.selectedAnswer == answer && viewModel.isAnswerCorrect == false) ? shakeOffset() : 0)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Styling Helpers
    
    private func buttonBackgroundColor(for answer: String) -> Color {
        if viewModel.selectedAnswer == answer {
            if viewModel.isAnswerCorrect == true {
                return Color.green
            } else if viewModel.isAnswerCorrect == false {
                return Color.red
            }
        }
        // If an answer is locked, visually highlight the correct answer in green even if they didn't pick it
        if viewModel.isAnswerLocked && answer == viewModel.questions[viewModel.currentIndex].decodedCorrectAnswer {
            return Color.green.opacity(0.6)
        }
        return Color(.systemBackground)
    }
    
    private func buttonTextColor(for answer: String) -> Color {
        if viewModel.selectedAnswer == answer || (viewModel.isAnswerLocked && answer == viewModel.questions[viewModel.currentIndex].decodedCorrectAnswer) {
            return .white
        }
        return .primary
    }
    
    // A simple hack to trigger a shake using SwiftUI offset combined with an implicit animation block inside the ViewModel delay.
    // However, to make it truly shake, we'd need a more complex GeometryEffect. 
    // For simplicity, we just use a small offset transition.
    private func shakeOffset() -> CGFloat {
        // We will just return 10 for a slight shift as a basic visual cue
        return 10
    }
}
