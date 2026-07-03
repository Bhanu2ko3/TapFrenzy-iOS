import SwiftUI

struct HistoryView: View {
    @AppStorage("game_history") private var historyJSON: String = "[]"
    
    var history: [RoundResult] {
        RoundResult.load(from: historyJSON).sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        VStack {
            if history.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Game History Yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            } else {
                List(history) { result in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(result.gameMode)
                                .font(.headline)
                            Spacer()
                            Text("\(result.score) pts")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Player: \(result.playerName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(result.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Game History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        historyJSON = "[]"
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
