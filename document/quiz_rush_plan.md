# Quiz Rush (Week 3) - Implementation Plan

This document outlines the architecture and tasks required to build the "Quiz Rush" game mode, strictly adhering to the requirements provided in the Week 3 assignment brief.

## Core Concepts & Architecture

We will implement a clean **MVVM (Model-View-ViewModel)** architecture for this game mode. This is specifically requested in the assignment to separate game logic from the UI.

### 1. Data Model (Model)
- **`TriviaQuestion.swift`**: We will create a `Codable` struct that perfectly matches the JSON structure from `opentdb.com`.
- It will map the `correct_answer` and `incorrect_answers` array.
- A computed property will dynamically shuffle and combine the 1 correct + 3 incorrect answers into a single array so the UI can just loop through 4 buttons.

### 2. Network Service
- **`TriviaService.swift`**: A dedicated Swift file containing a `fetchQuestions()` method.
- This method will use modern Swift Concurrency (`async/await`) and `URLSession.shared.data(from:)` to fetch 10 questions.
- It will gracefully handle network errors or decoding failures and `throw` them back to the ViewModel.

### 3. Logic Manager (ViewModel)
- **`QuizViewModel.swift`**: This class will conform to `ObservableObject`.
- **View States**: It will use an `enum ViewState { case loading, loaded, failed, completed }` to manage exactly what the UI should display at any given millisecond.
- **Published Properties**: It will hold `@Published` variables for the `questions` array, current `score`, current `streak`, and the `viewState`.
- **Game Loop**: It will contain the `submitAnswer()` logic. If correct, score +1 and streak +1. If wrong, streak resets. It will also track the current question index and move to `.completed` after 10 questions.

### 4. User Interface (View)
- **`QuizRushGameView.swift`**: The main SwiftUI view. 
- It will initialize `@StateObject private var viewModel = QuizViewModel()`.
- It will use the `.task` modifier to trigger `viewModel.loadGame()` as soon as the view appears.
- It will use a `Switch` statement on `viewModel.viewState`:
    - **loading**: Show a native `ProgressView` (spinner).
    - **failed**: Show a professional error message with a "Retry Connection" button.
    - **loaded**: Show the current question, streak counter, and 4 dynamically colored answer buttons.
- **Animations**: We will implement custom SwiftUI animations. When a user taps a button, it will briefly flash **Green** (if correct) or **Red** (with a shake effect, if wrong), before sliding to the next question.
- **`QuizGameOverView.swift`**: Will display the final score and save the match result into our existing `@AppStorage("game_history")` `RoundResult` architecture, ensuring it shows up in the Global History View!

## Maintaining the Aesthetic
- Following our established rules, **NO EMOJIS** will be used.
- We will use Apple's native `SF Symbols` for all iconography (e.g., `brain.head.profile`, `xmark.circle`, `checkmark.circle`).
- Code will remain clean, legible, and perfectly suited for a university-level assessment submission.
