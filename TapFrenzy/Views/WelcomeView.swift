import SwiftUI

struct WelcomeView: View {
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @State private var inputName: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Welcome to Speed Arcade")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Please enter your name to start playing and track your high scores.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter your name", text: $inputName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 40)
            
            Button(action: {
                if inputName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showAlert = true
                } else {
                    withAnimation(.easeInOut) {
                        playerName = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Name"), message: Text("Please enter a valid name to continue."), dismissButton: .default(Text("OK")))
            }
            
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
