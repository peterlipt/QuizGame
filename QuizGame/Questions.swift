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

    init(index: Int, difficulty: String, questionText: String, answerA: String, answerB: String, answerC: String, answerD: String, correctAnswer: String, category: QuestionTopic) {
        self.index = index
        self.difficulty = difficulty
        self.questionText = questionText
        self.answerA = answerA
        self.answerB = answerB
        self.answerC = answerC
        self.answerD = answerD
        self.correctAnswer = correctAnswer
        self.category = category
    }
    
    // Megtartjuk a String alapú inicializálót is a kompatibilitás miatt
    convenience init(index: Int, difficulty: String, questionText: String, answerA: String, answerB: String, answerC: String, answerD: String, correctAnswer: String, category: String) {
        let categoryTopic = QuestionTopic.getOrCreate(named: category)
        self.init(index: index, difficulty: difficulty, questionText: questionText, answerA: answerA, answerB: answerB, answerC: answerC, answerD: answerD, correctAnswer: correctAnswer, category: categoryTopic)
    }
}
