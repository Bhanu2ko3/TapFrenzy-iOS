import Charts
import SwiftUI

struct StatsTab: View {
    @StateObject private var viewModel = StatsVM()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Total Played")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(viewModel.totalGamesPlayed)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 5)
                        
                        VStack(alignment: .leading) {
                            Text("Total Score")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(viewModel.totalAccumulatedPoints)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 5)
                    }
                    .padding(.horizontal)
                    
                    HubActionCard(title: "Personal Bests", iconName: "star.fill", highlightColor: .yellow) {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Tap Frenzy")
                                Spacer()
                                Text("\(viewModel.tapFrenzyBest) pts")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            Divider()
                            HStack {
                                Text("Light It Up")
                                Spacer()
                                Text("\(viewModel.lightItUpBest) pts")
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                            Divider()
                            HStack {
                                Text("Quiz Rush")
                                Spacer()
                                Text("\(viewModel.quizRushBest) pts")
                                    .fontWeight(.bold)
                                    .foregroundColor(.indigo)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.gameHistory.isEmpty {
                        HubActionCard(title: "Points Chart", iconName: "chart.bar.fill", highlightColor: .green) {
                            Chart(viewModel.gameHistory.prefix(15)) { session in
                                BarMark(
                                    x: .value("Session", session.playedAt, unit: .second),
                                    y: .value("Score", session.finalScore)
                                )
                                .foregroundStyle(session.mode == .frenzySpeed ? Color.blue : (session.mode == .gridMatch ? Color.purple : Color.indigo))
                            }
                            .frame(height: 180)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        
                        HubActionCard(title: "Recent Games", iconName: "clock.fill", highlightColor: .orange) {
                            VStack(spacing: 12) {
                                ForEach(viewModel.gameHistory.prefix(5)) { session in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.mode == .frenzySpeed ? "Tap Frenzy" : (session.mode == .gridMatch ? "Light It Up" : "Quiz Rush"))
                                                .font(.headline)
                                            Text(session.playedAt, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("\(session.finalScore) pts")
                                            .font(.headline)
                                            .foregroundColor(session.mode == .frenzySpeed ? .blue : (session.mode == .gridMatch ? .purple : .indigo))
                                    }
                                    if session.id != viewModel.gameHistory.prefix(5).last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 15) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No session records found. Play a game to record stats!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .navigationTitle("Analytics")
            .onAppear {
                viewModel.refreshStatistics()
            }
        }
    }
}
