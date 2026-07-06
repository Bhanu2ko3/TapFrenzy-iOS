import Foundation

struct HubGameSession: Identifiable, Codable {
    let id: UUID
    let mode: AppGameMode
    let finalScore: Int
    let playedAt: Date
    let locLatitude: Double
    let locLongitude: Double
}

extension Array where Element == HubGameSession {
    static func deserialize(from jsonText: String) -> [HubGameSession] {
        guard let rawData = jsonText.data(using: .utf8) else {
            return []
        }
        let decodedList = try? JSONDecoder().decode([HubGameSession].self, from: rawData)
        return decodedList ?? []
    }

    static func serialize(_ sessionList: [HubGameSession]) -> String {
        guard let encodedData = try? JSONEncoder().encode(sessionList),
              let jsonString = String(data: encodedData, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
}
