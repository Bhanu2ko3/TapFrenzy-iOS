import Foundation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

extension Array where Element == GameSession {
    static func deserialize(from jsonText: String) -> [GameSession] {
        guard let rawData = jsonText.data(using: .utf8) else {
            return []
        }
        let decodedList = try? JSONDecoder().decode([GameSession].self, from: rawData)
        return decodedList ?? []
    }

    static func serialize(_ sessionList: [GameSession]) -> String {
        guard let encodedData = try? JSONEncoder().encode(sessionList),
              let jsonString = String(data: encodedData, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
}
