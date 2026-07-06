import Foundation

enum NetworkError: Error {
    case invalidURL
    case transportError
    case parsingError
}

struct HubTriviaService {
    static func fetchQuestions() async throws -> [TriviaQuestion] {
        let endpoint = "https://opentdb.com/api.php?amount=10&type=multiple"
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.transportError
        }
        do {
            let parsedResult = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return parsedResult.results
        } catch {
            throw NetworkError.parsingError
        }
    }
}
