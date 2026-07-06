import SwiftUI

struct SettingsTab: View {
    @AppStorage("dailyNotificationsEnabled") private var notificationsEnabled = false
    @State private var targetTime = Date()
    @State private var showingResetConfirmation = false
    @StateObject private var statsViewModel = StatsVM()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Arcade Challenge")) {
                    Toggle("Enable Daily Reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                NotificationService.requestAuthorization()
                                NotificationService.scheduleDailyChallenge(at: targetTime)
                            } else {
                                NotificationService.cancelAllNotifications()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Reminder Time", selection: $targetTime, displayedComponents: .hourAndMinute)
                            .onChange(of: targetTime) { newTime in
                                NotificationService.scheduleDailyChallenge(at: newTime)
                            }
                    }
                }
                
                Section(header: Text("Arcade Database")) {
                    Button(action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear All Stats")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Are you absolutely sure?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Erase All Data", role: .destructive) {
                    statsViewModel.eraseAllLedgerData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently wipe your scores, game sessions, and geotag pins.")
            }
        }
    }
}
