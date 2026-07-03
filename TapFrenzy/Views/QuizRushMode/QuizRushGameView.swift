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
        .onDisappear {
            viewModel.stopTimer()
        }
    }
    
    // Extracted view for the loaded state to keep body clean
    private var loadedView: some View {
        VStack(spacing: 25) {
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
            .padding(.top, 10)
            
            // Score Display
            Text("Score: \(viewModel.score)")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(.indigo)
            
            // Timer Bar
            VStack(spacing: 5) {
                ProgressView(value: Double(viewModel.timeRemaining), total: 20.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: timerColor()))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
                
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(timerColor())
                    Text("\(viewModel.timeRemaining)s")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(timerColor())
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Question Display with clean UI
            let currentQuestion = viewModel.questions[viewModel.currentIndex]
            
            VStack(spacing: 15) {
                Image(systemName: "quote.opening")
                    .font(.largeTitle)
                    .foregroundColor(.indigo.opacity(0.5))
                
                Text(currentQuestion.decodedQuestion)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .animation(.easeInOut, value: viewModel.currentIndex)
            }
            .padding(25)
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Answers Grid
            VStack(spacing: 15) {
                ForEach(viewModel.currentAnswers, id: \.self) { answer in
                    Button(action: {
                        viewModel.submitAnswer(answer)
                    }) {
                        Text(answer)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(buttonTextColor(for: answer))
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .background(buttonBackgroundColor(for: answer))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(buttonBorderColor(for: answer), lineWidth: 2)
                            )
                            .shadow(color: buttonBorderColor(for: answer).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(viewModel.isAnswerLocked)
                    // Apply a shake offset if this was the selected wrong answer
                    .offset(x: (viewModel.selectedAnswer == answer && viewModel.isAnswerCorrect == false) ? shakeOffset() : 0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Styling Helpers
    
    private func timerColor() -> Color {
        if viewModel.timeRemaining > 10 { return .green }
        if viewModel.timeRemaining > 5 { return .orange }
        return .red
    }
    
    private func buttonBackgroundColor(for answer: String) -> Color {
        if viewModel.selectedAnswer == answer {
            if viewModel.isAnswerCorrect == true {
                return Color.green
            } else if viewModel.isAnswerCorrect == false {
                return Color.red
            }
        }
        if viewModel.isAnswerLocked && answer == viewModel.questions[viewModel.currentIndex].decodedCorrectAnswer {
            return Color.green.opacity(0.8)
        }
        return Color(.systemBackground)
    }
    
    private func buttonTextColor(for answer: String) -> Color {
        if viewModel.selectedAnswer == answer || (viewModel.isAnswerLocked && answer == viewModel.questions[viewModel.currentIndex].decodedCorrectAnswer) {
            return .white
        }
        return .primary
    }
    
    private func buttonBorderColor(for answer: String) -> Color {
        if viewModel.selectedAnswer == answer {
            if viewModel.isAnswerCorrect == true { return .green }
            if viewModel.isAnswerCorrect == false { return .red }
        }
        if viewModel.isAnswerLocked && answer == viewModel.questions[viewModel.currentIndex].decodedCorrectAnswer {
            return .green
        }
        return Color.indigo.opacity(0.3)
    }
    
    private func shakeOffset() -> CGFloat {
        return 8
    }
}
