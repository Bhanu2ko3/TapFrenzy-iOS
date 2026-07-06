import Foundation

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case type, difficulty, category, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    var decodedQuestion: String {
        return question
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&shy;", with: "-")
    }
    
    var decodedCorrectAnswer: String {
        return correctAnswer
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
    
    var allAnswers: [String] {
        var answers = incorrectAnswers.map { 
            $0.replacingOccurrences(of: "&quot;", with: "\"")
              .replacingOccurrences(of: "&#039;", with: "'")
              .replacingOccurrences(of: "&amp;", with: "&")
        }
        answers.append(decodedCorrectAnswer)
        return answers.shuffled()
    }
}
