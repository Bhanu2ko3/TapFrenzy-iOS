import Foundation

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
