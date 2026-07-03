//
//  TapFrenzyApp.swift
//  TapFrenzy
//
//  Created by codebroai on 2026-06-12.
//

import SwiftUI

@main
struct TapFrenzyApp: App {
    @AppStorage("currentPlayerName") private var playerName: String = ""
    @AppStorage("appTheme") private var appTheme: Int = 0

    var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case 1: return .light
        case 2: return .dark
        default: return nil // System default
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if playerName.isEmpty {
                    WelcomeView()
                } else {
                    HomeView()
                }
            }
            .preferredColorScheme(preferredColorScheme)
        }
    }
}

// MARK: - Welcome View
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

// MARK: - Data Model
struct RoundResult: Identifiable, Codable {
    var id = UUID()
    let playerName: String
    let gameMode: String
    let score: Int
    let date: Date
    
    // Helper to save array to JSON string for @AppStorage
    static func save(_ results: [RoundResult]) -> String {
        guard let data = try? JSONEncoder().encode(results),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }
    
    // Helper to load array from JSON string
    static func load(from string: String) -> [RoundResult] {
        guard let data = string.data(using: .utf8),
              let results = try? JSONDecoder().decode([RoundResult].self, from: data) else {
            return []
        }
        return results
    }
}
