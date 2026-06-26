
import SwiftUI

struct HomeView: View {
    // MARK: - Persisted High Scores per Mode
    @AppStorage("highScore_tapFrenzy") private var tapFrenzyHighScore = 0
    @AppStorage("highScore_lightItUp") private var lightItUpHighScore = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 35) {
                // Main Dashboard Header
                VStack(spacing: 10) {
                    Text("Speed Arcade 🕹️")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Select a game mode to test your reflexes!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
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
                                Text("High Score: \(tapFrenzyHighScore)") // Displays persisted score
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
                    NavigationLink(destination: Text("Light It Up Game Mode Coming Soon! ⏱️")) {
                        HStack {
                            Image(systemName: "square.grid.3x3.topleft.filled")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Light It Up")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("High Score: \(lightItUpHighScore)") // Displays persisted score
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
