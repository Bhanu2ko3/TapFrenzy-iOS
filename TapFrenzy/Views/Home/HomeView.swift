import SwiftUI

struct HomeView: View {
    // MARK: - Persisted User Data
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("highScore_tapFrenzy") private var tapFrenzyHighScore = 0
    @AppStorage("highScore_lightItUp") private var lightItUpHighScore = 0
    
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
                    Button(action: {
                        withAnimation {
                            playerName = ""
                        }
                    }) {
                        Text("Change")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                    }
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
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
