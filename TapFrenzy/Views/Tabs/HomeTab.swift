import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
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
                .padding(.top, 40)
                
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
        }
    }
}
