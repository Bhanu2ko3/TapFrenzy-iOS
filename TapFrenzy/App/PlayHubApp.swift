import SwiftUI

@main
struct PlayHubApp: App {
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("appTheme") private var appTheme: Int = 0
    
    var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if playerName.isEmpty {
                    WelcomeView()
                } else {
                    PlayHubMainApp()
                }
            }
            .preferredColorScheme(preferredColorScheme)
        }
    }
}

struct WelcomeView: View {
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @State private var inputName: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.3), radius: 10)
            
            Text("Welcome to PlayHub")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text("Enter your name to start playing and track your arcade history.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            TextField("Enter your name", text: $inputName)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal, 40)
            
            Button(action: {
                let trimmed = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    withAnimation {
                        playerName = trimmed
                    }
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 8)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}
