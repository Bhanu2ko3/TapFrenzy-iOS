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

    var body: some Scene {
        WindowGroup {
            if playerName.isEmpty {
                WelcomeView()
            } else {
                HomeView()
            }
        }
    }
}
