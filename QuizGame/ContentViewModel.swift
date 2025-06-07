import Foundation

@Observable class ContentViewModel : ObservableObject {

    var questions: [Question] = []
    var selectedCategory: QuestionTopic? = nil
    var selectedDifficulty: String? = nil
    var currentQuestion: Question? = nil
    var difficulties: Array<String> = ["All"]
    var selectedCSVFile: String = "komhal" // Default CSV file name (without .csv)
    var availableCSVFiles: [String] = []
    var availableCategories: [QuestionTopic] = [] // Csak az aktuális fájlban szereplő kategóriák

    init() {
        self.selectedCategory = QuestionTopic.allTopics.first
        self.loadAvailableCSVFiles()
        self.loadQuestions()
    }

    private func loadAvailableCSVFiles() {
        print("🔍 Kezdem a CSV fájlok keresését...")
        
        // Bundle path kiírása diagnózishoz
        print("📂 Bundle path: \(Bundle.main.bundlePath)")
        
        // Különböző helyeken keresés debug infóval
        let questionsDirUrl = Bundle.main.bundleURL.appendingPathComponent("questions")
        print("📂 Questions mappa elérési útja: \(questionsDirUrl.path)")
        print("📂 Questions mappa létezik? \(FileManager.default.fileExists(atPath: questionsDirUrl.path))")
        
        // CSV fájlok keresése és listázása a projektben elérhető src mappában is
        let srcDirPath = Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("src").path
        print("📂 src mappa elérési útja: \(srcDirPath)")
        print("📂 src mappa létezik? \(FileManager.default.fileExists(atPath: srcDirPath))")
        
        // Próbáljuk először a questions almappából
        print("🔍 Keresés a 'questions' almappában...")
        if let urls = Bundle.main.urls(forResourcesWithExtension: "csv", subdirectory: "questions") {
            self.availableCSVFiles = urls.compactMap { $0.deletingPathExtension().lastPathComponent }
            print("✅ CSV fájlok a 'questions' almappában: \(self.availableCSVFiles)")
        }
        // Ha nem találtunk semmit, próbáljuk a főkönyvtárból
        else {
            print("❌ Nem találtam CSV fájlokat a 'questions' almappában")
            print("🔍 Keresés a főkönyvtárban...")
            if let urls = Bundle.main.urls(forResourcesWithExtension: "csv", subdirectory: nil) {
                self.availableCSVFiles = urls.compactMap { $0.deletingPathExtension().lastPathComponent }
                print("✅ CSV fájlok a főkönyvtárban: \(self.availableCSVFiles)")
            }
            // Ha még mindig nincs találat, próbáljuk közvetlenül a fájlrendszerből olvasni
            else {
                print("❌ Nem találtam CSV fájlokat a főkönyvtárban sem")
                print("🔍 Közvetlen keresés a fájlrendszerben (src mappa)...")
                
                // Fallback: kerdesek.csv a src mappából
                if FileManager.default.fileExists(atPath: srcDirPath) {
                    do {
                        let srcContents = try FileManager.default.contentsOfDirectory(atPath: srcDirPath)
                        let csvFiles = srcContents.filter { $0.hasSuffix(".csv") }
                        self.availableCSVFiles = csvFiles.compactMap { filename in
                            if let dotIndex = filename.lastIndex(of: ".") {
                                return String(filename[..<dotIndex])
                            } else {
                                return filename
                            }
                        }
                        print("✅ CSV fájlok az src mappában: \(self.availableCSVFiles)")
                    } catch {
                        print("❌ Hiba az src mappa olvasásakor: \(error)")
                        self.availableCSVFiles = ["komhal"]
                    }
                } else {
                    // Alapértelmezett fallback
                    self.availableCSVFiles = ["komhal"]
                    print("⚠️ Alapértelmezett 'komhal' használata: \(self.availableCSVFiles)")
                }
            }
        }
    }
    
    private func readAllQuestions(from fileName: String) -> [Question]? {
        var fileURL: URL?
        
        // 1. Először keresés a questions mappában
        if let url = Bundle.main.url(forResource: fileName, withExtension: "csv", subdirectory: "questions") {
            fileURL = url
            print("📄 Fájl megtalálva a questions mappában: \(url.path)")
        }
        // 2. Keresés a fő bundle-ben
        else if let url = Bundle.main.url(forResource: fileName, withExtension: "csv") {
            fileURL = url
            print("📄 Fájl megtalálva a fő bundle-ben: \(url.path)")
        }
        // 3. Fallback: próbáljuk közvetlenül az src mappából
        else {
            let srcDirPath = Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("src").path
            let filePath = "\(srcDirPath)/\(fileName).csv"
            if FileManager.default.fileExists(atPath: filePath) {
                fileURL = URL(fileURLWithPath: filePath)
                print("📄 Fájl megtalálva az src mappában: \(filePath)")
            } else {
                print("❌ File \(fileName).csv not found anywhere!")
                return nil
            }
        }
        
        do {
            let data = try String(contentsOf: fileURL!, encoding: .utf8)
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
                    
                    // Get or create the appropriate QuestionTopic
                    let categoryTopic = QuestionTopic.getOrCreate(named: category)
                    
                    // Create a Question instance with the QuestionTopic object directly
                    let question = Question(index: index, difficulty: difficulty, questionText: questionText, answerA: answerA, answerB: answerB, answerC: answerC, answerD: answerD, correctAnswer: correctAnswer, category: categoryTopic)
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
        let previouslySelectedCategory = self.selectedCategory
        // Töröljük a kategóriákat fájlváltáskor
        self.availableCategories.removeAll()
        self.selectedCategory = nil
        guard let allQuestions = readAllQuestions(from: selectedCSVFile) else {
            print("Cannot load questions from \\(selectedCSVFile)!")
            return
        }
        // Kategóriák szűrése az aktuális fájl alapján
        let uniqueCategories = Array(Set(allQuestions.map { $0.category })).sorted { $0.name < $1.name }
        self.availableCategories = uniqueCategories
        
        // Visszaállítjuk a korábban kiválasztott kategóriát, ha még létezik az új fájlban
        if let prevCategory = previouslySelectedCategory, uniqueCategories.contains(where: { $0.id == prevCategory.id }) {
            self.selectedCategory = prevCategory
        } else {
            // Ha nem, vagy nem volt korábban kiválasztva, akkor az elsőt válasszuk
            self.selectedCategory = uniqueCategories.first
        }
        
        // Filter by category if set.
        var filtered = allQuestions
        if let category = self.selectedCategory {
            filtered = filtered.filter { $0.category.id == category.id }
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
