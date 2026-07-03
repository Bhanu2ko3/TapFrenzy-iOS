import Foundation

enum NetworkError: Error {
    case badURL
    case requestFailed
    case decodingFailed
}

struct TriviaService {
    // Fetches 10 multiple-choice questions from OpenTDB
    static func fetchQuestions() async throws -> [TriviaQuestion] {
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed
        }
        
        do {
            let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return triviaResponse.results
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
