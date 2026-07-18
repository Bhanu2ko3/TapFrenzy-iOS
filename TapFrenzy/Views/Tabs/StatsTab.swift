import Charts
import SwiftUI

struct ChartData: Identifiable {
    let id: UUID
    let label: String
    let score: Int
    let mode: GameMode
}

struct StatsTab: View {
    @StateObject private var viewModel = StatsVM()
    @State private var visibleLimit: Int = 10
    
    var chartData: [ChartData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let recent = Array(viewModel.gameHistory.prefix(7)).reversed()
        return recent.enumerated().map { index, session in
            ChartData(
                id: session.id,
                label: "#\(recent.count - index) (\(formatter.string(from: session.timestamp)))",
                score: session.score,
                mode: session.mode
            )
        }
    }
    
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
                            Chart(chartData) { data in
                                BarMark(
                                    x: .value("Session", data.label),
                                    y: .value("Score", data.score)
                                )
                                .foregroundStyle(data.mode == .frenzySpeed ? Color.blue : (data.mode == .gridMatch ? Color.purple : Color.indigo))
                            }
                            .frame(height: 180)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        
                        HubActionCard(title: "Recent Games", iconName: "clock.fill", highlightColor: .orange) {
                            VStack(spacing: 12) {
                                ForEach(Array(viewModel.gameHistory.prefix(visibleLimit))) { session in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.mode == .frenzySpeed ? "Tap Frenzy" : (session.mode == .gridMatch ? "Light It Up" : "Quiz Rush"))
                                                .font(.headline)
                                            
                                            HStack {
                                                Text("Player: \(session.playerName)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text("•")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(session.timestamp, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        Text("\(session.score) pts")
                                            .font(.headline)
                                            .foregroundColor(session.mode == .frenzySpeed ? .blue : (session.mode == .gridMatch ? .purple : .indigo))
                                    }
                                    if session.id != viewModel.gameHistory.prefix(visibleLimit).last?.id {
                                        Divider()
                                    }
                                }
                                
                                if viewModel.gameHistory.count > visibleLimit {
                                    Button(action: {
                                        withAnimation {
                                            visibleLimit += 10
                                        }
                                    }) {
                                        Text("Load More")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)
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
