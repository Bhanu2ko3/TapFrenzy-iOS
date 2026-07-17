# 🎮 PlayHub: Arcade & Knowledge Suite (TapFrenzy)

PlayHub is a structured, highly polished iOS application built entirely with **SwiftUI** and native Apple frameworks. It wraps three mini-games, dynamic statistics dashboards, user profile management, CoreLocation geotagging, and local push notifications into a premium, unified tab-based app shell.

---

## ✨ Features List

### 📱 Core App Shell
- **User Profile Management**: A personalized welcome screen prompts players to register their name. A floating Profile sheet calculates personal stats (total score, total games, favorite game mode) and isolates their personal history list with standard sign-out.
- **Tab Bar Interface**: A persistent `TabView` navigation shell dividing the app into 4 distinct areas: Home, Stats, Map, and Settings.
- **Premium UI & Theming**: Dark/Light mode theme selections persisted globally, using custom navigation bar elements and professional SF Symbols.

### 🕹 Mini-Games
1. **Tap Frenzy**: A fast-paced, 10-second button-mashing reflex test. The tap button continuously scales down as time ticks away. The button jumps to a random layout offset on every single tap from the start. Includes bonus/penalty modifier states.
2. **Light It Up**: A Whack-a-Mole coordinate challenge. Tap the lit grids before they shift. Every 15 seconds, the difficulty escalates by growing the grid size (from 3x3 to 3x4, then 4x4) and speed increases.
3. **Quiz Rush**: A 10-question general knowledge trivia quiz using the Open Trivia DB API. Features a 20-second countdown timer per question, answer validation states, consecutive streak multipliers, and streak animations.

### 📍 Platform Integrations
- **Map of Games (Geotagging)**: Uses Core Location to record the exact GPS coordinates of where each score was achieved. The Map tab plots these sessions as pins showing the final score.
- **Daily Challenge Reminders**: Integrates UserNotifications. The Settings tab lets the player configure a specific time to schedule a daily local notification reminding them to play.
- **ShareLink Integration**: Generates a share string on the Result screen ("I just scored 47 on Quiz Rush — beat that!") and opens the native system share sheet.

---

## 🛠 Architecture Overview

The codebase is built on the **MVVM (Model-View-ViewModel)** design pattern, promoting clean separation of concerns:

- **Models**: Simple, immutable data structures representing core entities (`GameSession`, `GameMode`, `TriviaQuestion`). The `GameSession` struct conforms to `Codable` and `Identifiable` for quick serialization.
- **ViewModels**: Manage screen states, publish reactive updates, and drive timer cycles. They handle database operations, ensuring the views remain lightweight and stateless.
- **Views**: SwiftUI view declarations. They bind reactively to ViewModel properties and reflect changes dynamically.
- **Services**: Standalone controllers that wrap hardware interfaces or external APIs:
  - `LocationService`: Obtains GPS coordinates asynchronously.
  - `NotificationService`: Manages local scheduling with `UNUserNotificationCenter`.
  - `TriviaAPI`: Handles HTTP asynchronous network requests.
- **Thread Safety**: ViewModels and UI updates are isolated to the `@MainActor` to prevent multi-threaded UI access warnings.
- **Data Persistence**: Sessions are serialized into JSON arrays and stored persistently in `UserDefaults` under a single global ledger key (`hub_ledger`).

---

## 📁 Project Folder Structure

The project has been refactored into the following standard directories:

```
TapFrenzy/
├── App/
│   └── PlayHubApp.swift          # App main entry point
├── Models/
│   ├── GameMode.swift            # GameMode enum configuration
│   ├── GameSession.swift         # GameSession Codable data model
│   └── TriviaQuestion.swift      # Trivia quiz API response models
├── ViewModels/
│   ├── TapFrenzyVM.swift         # Tap game state engine
│   ├── LightItUpVM.swift         # Coordinate card grid game engine
│   ├── QuizRushVM.swift          # Trivia network engine & timers
│   └── StatsVM.swift             # Analytics compilation & reset engine
├── Services/
│   ├── LocationService.swift     # CoreLocation manager wrapper
│   ├── NotificationService.swift # Local user notifications scheduler
│   └── TriviaAPI.swift           # async/await HTTP network client
├── Views/
│   ├── Tabs/
│   │   ├── HomeTab.swift         # Main dashboard & Profile panel
│   │   ├── StatsTab.swift        # Analytics numbers, bar chart & global history
│   │   ├── MapTab.swift          # MapKit pins & list layout
│   │   └── SettingsTab.swift     # Theme selection, reminders & reset buttons
│   ├── Games/
│   │   ├── TapFrenzyView.swift   # Tap game UI
│   │   ├── LightItUpView.swift   # Whack-a-mole card grid UI
│   │   └── QuizRushView.swift    # Trivia question options UI
│   └── Shared/
│       ├── ResultView.swift      # Game over score sheet with ShareLink
│       └── ScoreBadge.swift      # Reusable score element UI
```

---

## ⚠️ Known Limitations

1. **Map Rendering on QEMU macOS VMs**: Apple Maps requires Metal GPU hardware acceleration to render vector tiles and overlay annotations. In virtualized macOS QEMU environments lacking GPU virtualization support, the Map tab displays a solid background color and skips rendering overlays. 
   - *Fallback Mechanism*: To bypass this virtualization limitation, a detailed "Recorded Locations" table is integrated directly below the Map view. This displays all logged coordinates (lat/lon), game modes, and scores, proving that GPS tracking and ledger reading are fully functional.
2. **Internet Dependency for Trivia Quiz**: The Quiz Rush mode fetches questions from an online Open Trivia database. If no internet connection is available, the VM handles the connection failure gracefully and displays a recovery retry screen.

---

## 📝 Reflection

1. **Monolithic Refactoring**: Moving from three standalone game views to a unified tab bar architecture showed the value of structural refactoring. Creating a shared model (`GameSession`) and a global JSON ledger in `UserDefaults` made it possible to unify analytics, map pins, and leaderboards under a single data source.
2. **SwiftUI Concurrency & Threading**: Working with Core Location delegates highlighted the importance of main-thread isolation in SwiftUI. Wrapping background thread notifications inside asynchronous task calls to `@MainActor` resolved UI publishing race conditions.
3. **Swift Charts Temporal Scale Challenges**: Implementing the Analytics bar chart revealed that mapping dates directly to the x-axis causes bar widths to collapse to single pixels if sessions are logged minutes apart. Standardizing the x-axis to categorical labels (combining ordinal index and short-time strings) forced Swift Charts to render readable, bold bars.
