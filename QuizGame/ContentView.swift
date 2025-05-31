// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var defaultGradient: [Color] = [Color.black, Color.gray]
    @State private var backgroundGradient: [Color] = [Color.black, Color.gray]
    @State private var showFeedback = false
    @State private var answerFeedback = ""
    
    // For dropdown menus.
    @State private var selectedCategory: QuestionTopic? = nil
    @State private var selectedDifficulty: String = "All"
    
    // To highlight the correct answer button when the answer is wrong.
    @State private var highlightedCorrectAnswer: Int? = nil
    // Új állapot változó a "Következő kérdés" gombhoz
    @State private var showNextButton = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: backgroundGradient),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView { // <-- ScrollView hozzáadva
                VStack {
                    // Top bar with dropdown menus.
                    HStack {
                        // Category picker.
                        Menu {
                            Button("All") {
                                selectedCategory = nil
                                viewModel.selectedCategory = nil
                                viewModel.loadQuestions()
                                viewModel.getNextQuestion()
                            }
                            ForEach(QuestionTopic.allCases, id: \.self) { category in
                                Button("\(category.rawValue)") {
                                    selectedCategory = category
                                    viewModel.selectedCategory = category
                                    viewModel.loadQuestions()
                                    viewModel.getNextQuestion()
                                }
                            }
                        } label: {
                            Label("Category: \(selectedCategory?.rawValue ?? "All")",
                                  systemImage: "line.horizontal.3.decrease.circle")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.7))
                                .cornerRadius(10)
                        }
                        
                        // Difficulty picker.
                        Menu {
                            ForEach(viewModel.difficulties, id: \.self) { level in
                                Button(level) {
                                    selectedDifficulty = level
                                    viewModel.selectedDifficulty = level
                                    viewModel.loadQuestions()
                                    viewModel.getNextQuestion()
                            }
                                }
                        } label: {
                            Label("Difficulty: \(selectedDifficulty)",
                                  systemImage: "slider.horizontal.3")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    if let question = viewModel.currentQuestion {
                        VStack(spacing: 20) {
                            Text(question.questionText)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                            
                            ForEach(0..<4, id: \.self) { index in
                                Button(action: { checkAnswer(selectedIndex: index) }) {
                                    Text(getAnswerText(for: question, index: index))
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(highlightedCorrectAnswer == index ? Color.green : Color.gray.opacity(0.7))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .minimumScaleFactor(0.7)
                                }
                                // Gombok letiltása, ha showFeedback igaz
                                .disabled(showFeedback)
                            }
                            
                            if showFeedback {
                                Text(answerFeedback)
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .transition(.opacity)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                            }
                            // "Következő kérdés" gomb csak ha showNextButton igaz
                            if showNextButton {
                                Button("Következő kérdés") {
                                    // Ha helyes volt az előző válasz, töröljük a kérdést
                                    if answerFeedback == "Correct!" {
                                        viewModel.markCurrentQuestionAnsweredCorrectly()
                                    }
                                    withAnimation(.easeInOut) {
                                        showFeedback = false
                                        backgroundGradient = defaultGradient
                                        highlightedCorrectAnswer = nil
                                        showNextButton = false
                                    }
                                    viewModel.getNextQuestion()
                                }
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.7)
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 20) {
                            Text("No questions available.")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                            Button("Next Question") {
                                viewModel.getNextQuestion()
                            }
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.7)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadQuestions()
            viewModel.getNextQuestion()
        }
    }
    
    private func getAnswerText(for question: Question, index: Int) -> String {
        switch index {
        case 0: return question.answerA
        case 1: return question.answerB
        case 2: return question.answerC
        case 3: return question.answerD
        default: return ""
        }
    }
    
    private func convertLetterToIndex(letter: String) -> Int {
        switch letter {
        case "A": return 0
        case "B": return 1
        case "C": return 2
        case "D": return 3
        default: return -1
        }
    }
    
    private func checkAnswer(selectedIndex: Int) {
        guard let question = viewModel.currentQuestion else { return }
        let correctIndex = convertLetterToIndex(letter: question.correctAnswer)
        withAnimation(.easeInOut) {
            if getAnswerText(for: question, index: selectedIndex) ==
               getAnswerText(for: question, index: correctIndex) {
                backgroundGradient = [Color.green.opacity(0.5), Color.green]
                answerFeedback = "Correct!"
                highlightedCorrectAnswer = nil
            } else {
                backgroundGradient = [Color.red.opacity(0.5), Color.red]
                answerFeedback = "Wrong!"
                highlightedCorrectAnswer = correctIndex
            }
            showFeedback = true
            showNextButton = true // Következő gomb megjelenítése
        }
        // Az automatikus továbblépés eltávolítva
    }
}
