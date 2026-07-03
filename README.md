# 🎮 TapFrenzy: Speed Arcade

TapFrenzy is a dynamic, multi-game iOS application built entirely with **SwiftUI**. Designed as a university assignment, it features three exciting mini-games that test a player's reflexes, memory, and general knowledge. The app includes a global persistence layer to track high scores and player statistics across all game modes.

## ✨ Features

- **👤 Player Profiles & Global History**: Players register their names before playing. All scores are persistently saved using `@AppStorage`, complete with a dedicated global history dashboard.
- **⚡️ Tap Frenzy**: A fast-paced, 10-second button-mashing reflex test. Watch out for dynamically changing penalty colors!
- **💡 Light It Up**: A modern whack-a-mole style game. Tap the glowing cards before they shift. The grid expands and the speed increases every 15 seconds.
- **🧠 Quiz Rush**: A live trivia challenge powered by the [Open Trivia DB API](https://opentdb.com/). Features a 20-second timer per question, streak bonuses, and dynamic UI animations.

## 🛠 Architecture & Tech Stack

The project adheres to strict, clean coding standards with a focus on modularity and modern iOS development practices:

- **Framework**: SwiftUI (iOS 16+)
- **Architecture**: MVVM (Model-View-ViewModel) for complex modes like Quiz Rush.
- **Concurrency**: Modern Swift `async/await` for network requests.
- **Reactive Programming**: Combine framework (`Timer.publish`) for game loop engines and countdowns.
- **Persistence**: `@AppStorage` for lightweight, on-device JSON history tracking.

## 📁 Folder Structure

```
TapFrenzy/
│
├── Models/
│   ├── RoundResult.swift       # Global History Data Model
│   └── TriviaQuestion.swift    # API Response Models
│
├── Services/
│   └── TriviaService.swift     # async/await Network Manager
│
├── ViewModels/
│   └── QuizViewModel.swift     # State management & Timer logic
│
└── Views/
    ├── Home/                   # Welcome Screen & History Dashboard
    ├── TapFrenzyMode/          # Reflex Game Views
    ├── LightItUpMode/          # Grid Game Views
    └── QuizRushMode/           # Trivia Game Views
```

## 🚀 Getting Started

1. Clone the repository to your Mac.
2. Open `TapFrenzy.xcodeproj` in **Xcode**.
3. *Important Note*: Ensure that the `Models`, `Services`, `ViewModels`, and all sub-folders inside `Views` are properly linked in the Xcode Project Navigator. (If you see a "Cannot find in scope" error, simply drag and drop the missing folders from Finder into Xcode).
4. Select a Simulator (e.g., iPhone 14 Pro) or a physical device.
5. Click **Run** (Cmd + R) to build and launch the app!

## 🎨 UI/UX Highlights

- **No Emojis**: Fully professional UI utilizing **SF Symbols** exclusively.
- **Dynamic Animations**: Smooth transitions, scale effects, and custom gradient backgrounds.
- **Custom Navigation**: Premium, floating back buttons and consistent styling across all mini-games.

---
*Developed for BSc (Hons) Computing - iOS App Development Module.*
