import SwiftUI

struct HomeTab: View {
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @State private var showProfileSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome,")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(playerName)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Button(action: { showProfileSheet = true }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.primary)
                    
                    Text("PlayHub")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Arcade & Knowledge Suite")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 20) {
                    NavigationLink(destination: TapFrenzyView()) {
                        HubMenuButton(
                            iconName: "bolt.fill",
                            title: "Tap Frenzy",
                            subtitle: "Test your raw tapping speed",
                            themeColor: .blue
                        )
                    }
                    
                    NavigationLink(destination: LightItUpView()) {
                        HubMenuButton(
                            iconName: "square.grid.3x3.topleft.filled",
                            title: "Light It Up",
                            subtitle: "Whack-a-mole coordinate challenge",
                            themeColor: .purple
                        )
                    }
                    
                    NavigationLink(destination: QuizRushView()) {
                        HubMenuButton(
                            iconName: "brain.head.profile",
                            title: "Quiz Rush",
                            subtitle: "10 general knowledge questions",
                            themeColor: .indigo
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .navigationTitle("Dashboard")
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
            }
        }
    }
}

struct ProfileView: View {
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var items: [HubGameSession] = []
    
    var playerHistory: [HubGameSession] {
        items.filter { $0.playerName == playerName }.sorted(by: { $0.playedAt > $1.playedAt })
    }
    
    var totalGames: Int {
        playerHistory.count
    }
    
    var totalScore: Int {
        playerHistory.reduce(0) { $0 + $1.finalScore }
    }
    
    var favoriteGame: String {
        let modes = playerHistory.map { $0.mode }
        let counts = modes.reduce(into: [:]) { counts, mode in counts[mode, default: 0] += 1 }
        guard let maxMode = counts.max(by: { $0.1 < $1.1 })?.key else { return "None" }
        switch maxMode {
        case .frenzySpeed: return "Tap Frenzy"
        case .gridMatch: return "Light It Up"
        case .triviaQuiz: return "Quiz Rush"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .shadow(radius: 5)
                    
                    Text(playerName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                HStack(spacing: 16) {
                    VStack {
                        Text("Games")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalGames)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack {
                        Text("Total Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(totalScore)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack {
                        Text("Favorite")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(favoriteGame)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if playerHistory.isEmpty {
                        Text("No games played yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        List(playerHistory) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.mode == .frenzySpeed ? "Tap Frenzy" : (session.mode == .gridMatch ? "Light It Up" : "Quiz Rush"))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(session.playedAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("\(session.finalScore) pts")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
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
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                    .shadow(color: .red.opacity(0.3), radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                let rawLedger = UserDefaults.standard.string(forKey: "hub_ledger") ?? "[]"
                items = [HubGameSession].deserialize(from: rawLedger)
            }
        }
    }
}
