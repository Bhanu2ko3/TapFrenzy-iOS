import SwiftUI

struct HomeView: View {
    // MARK: - Persisted User Data
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("highScore_tapFrenzy") private var tapFrenzyHighScore = 0
    @AppStorage("highScore_lightItUp") private var lightItUpHighScore = 0
    @AppStorage("appTheme") private var appTheme: Int = 0
    
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 35) {
                
                // Header Area (Welcome & Change Player)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(playerName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    
                    // Theme Picker Menu
                    Menu {
                        Picker("Theme", selection: $appTheme) {
                            Text("System Default").tag(0)
                            Text("Light Mode").tag(1)
                            Text("Dark Mode").tag(2)
                        }
                    } label: {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    
                    // Profile Button
                    Button(action: {
                        showProfile = true
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 5)
                }
                .padding(.top, 10)
                
                // Main Title
                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.primary)
                    Text("Speed Arcade")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Select a game mode to test your reflexes!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Navigation Link Options Area
                VStack(spacing: 20) {
                    // MODE 1: Tap Frenzy
                    NavigationLink(destination: ContentView()) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tap Frenzy")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("High Score: \(tapFrenzyHighScore)")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // MODE 2: Light It Up
                    NavigationLink(destination: LightItUpGameView()) {
                        HStack {
                            Image(systemName: "square.grid.3x3.topleft.filled")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Light It Up")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("High Score: \(lightItUpHighScore)")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // MODE 3: Quiz Rush
                    @AppStorage("highScore_quizRush") var quizRushHighScore = 0
                    
                    NavigationLink(destination: QuizRushGameView()) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Quiz Rush")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("High Score: \(quizRushHighScore)")
                                    .font(.caption)
                                    .opacity(0.9)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .indigo.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // View History Button
                    NavigationLink(destination: HistoryView()) {
                        HStack {
                            Image(systemName: "chart.bar.doc.horizontal.fill")
                                .font(.headline)
                            Text("View All History")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(15)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("game_history") private var historyJSON: String = "[]"
    
    var history: [RoundResult] {
        RoundResult.load(from: historyJSON)
    }
    
    var totalGames: Int {
        history.count
    }
    
    var totalScore: Int {
        history.reduce(0) { $0 + $1.score }
    }
    
    var favoriteGame: String {
        let modes = history.map { $0.gameMode }
        let counts = modes.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        return counts.max(by: { $0.1 < $1.1 })?.key ?? "None"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(playerName)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                .padding(.top, 40)
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatBox(title: "Total Games", value: "\(totalGames)", icon: "gamecontroller.fill", color: .indigo)
                    StatBox(title: "Total Score", value: "\(totalScore)", icon: "star.fill", color: .yellow)
                }
                .padding(.horizontal, 30)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                    StatBox(title: "Top Mode", value: favoriteGame, icon: "trophy.fill", color: .orange)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    withAnimation {
                        playerName = ""
                        dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Player Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - History View
struct HistoryView: View {
    @AppStorage("game_history") private var historyJSON: String = "[]"
    
    var history: [RoundResult] {
        RoundResult.load(from: historyJSON).sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        VStack {
            if history.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Game History Yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            } else {
                List(history) { result in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(result.gameMode)
                                .font(.headline)
                            Spacer()
                            Text("\(result.score) pts")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Player: \(result.playerName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(result.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Game History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        historyJSON = "[]"
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
