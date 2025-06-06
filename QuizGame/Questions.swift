import Foundation

class Question {
    let index: Int
    let difficulty: String
    let questionText: String
    let answerA: String
    let answerB: String
    let answerC: String
    let answerD: String
    let correctAnswer: String
    let category: QuestionTopic

    init(index: Int, difficulty: String, questionText: String, answerA: String, answerB: String, answerC: String, answerD: String, correctAnswer: String, category: String) {
        self.index = index
        self.difficulty = difficulty
        self.questionText = questionText
        self.answerA = answerA
        self.answerB = answerB
        self.answerC = answerC
        self.answerD = answerD
        self.correctAnswer = correctAnswer
        self.category = QuestionTopic.getOrCreate(named: category)
    }
}
