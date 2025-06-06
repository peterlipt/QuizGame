import Foundation

@Observable class ContentViewModel : ObservableObject {

    var questions: [Question] = []
    var selectedCategory: QuestionTopic? = nil
    var selectedDifficulty: String? = nil
    var currentQuestion: Question? = nil
    var difficulties: Array<String> = ["All"]

    init() {
        self.selectedCategory = QuestionTopic.allTopics.first
        self.loadQuestions()
    }

    private func readAllQuestions(from fileName: String) -> [Question]? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            print("File \(fileName).csv not found!")
            return nil
        }
        
        do {
            let data = try String(contentsOf: fileURL, encoding: .utf8)
            var rows = data.components(separatedBy: "\n")
            rows = rows.filter { !$0.isEmpty }
            
            let dataRows = rows.dropFirst()
            var questions = [Question]()
            
            for row in dataRows {
                let columns = row.components(separatedBy: ";")
                if columns.count >= 9, let index = Int(columns[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
                    let difficulty = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !self.difficulties.contains(difficulty) {
                        self.difficulties.append(difficulty)
                    }
                    let questionText = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let answerA = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                    let answerB = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
                    let answerC = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
                    let answerD = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
                    let correctAnswer = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)
                    let category = columns[8].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Create a Question instance.
                    let question = Question(index: index, difficulty: difficulty, questionText: questionText, answerA: answerA, answerB: answerB, answerC: answerC, answerD: answerD, correctAnswer: correctAnswer, category: category)
                    questions.append(question)
                }
                difficulties = difficulties.sorted {
                    guard let first = Int($0), let second = Int($1) else {
                        return false
                    }
                    return first < second
                }

            }
            return questions
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
    
    func loadQuestions() {
        guard let allQuestions = readAllQuestions(from: "komhal") else {
            print("Cannot load questions!")
            return
        }
        
        // Filter by category if set.
        var filtered = allQuestions
        if let category = self.selectedCategory {
            filtered = filtered.filter { $0.category.id == category.id } // Use .rawValue for comparison
        }
        
        // Filter by difficulty if set and not equal to "All".
        if let difficulty = self.selectedDifficulty, difficulty != "All" {
            filtered = filtered.filter { $0.difficulty.lowercased() == difficulty.lowercased() }
        }
        
        self.questions = filtered
    }
    
    func getNextQuestion() {
        guard !self.questions.isEmpty else {
            self.currentQuestion = nil
            return
        }
        // Ne vegyük ki a kérdést, csak válasszunk egyet véletlenszerűen
        let randomIndex = Int(arc4random_uniform(UInt32(self.questions.count)))
        self.currentQuestion = self.questions[randomIndex]
    }

    // Új metódus: csak helyes válasz esetén hívjuk meg, hogy eltávolítsa a kérdést
    func markCurrentQuestionAnsweredCorrectly() {
        guard let current = self.currentQuestion else { return }
        if let idx = self.questions.firstIndex(where: { $0.index == current.index }) {
            self.questions.remove(at: idx)
        }
    }
}
