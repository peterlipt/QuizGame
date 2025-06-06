// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var defaultGradient: [Color] = [Color.black, Color.gray]
    @State private var backgroundGradient: [Color] = [Color.black, Color.gray]
    @State private var showFeedback = false
    @State private var answerFeedback = ""
    
    // For dropdown menus.
    @State private var selectedCategory: QuestionTopic? = QuestionTopic.allTopics.first // Default to first category
    @State private var selectedDifficulty: String = "All"
    
    // To highlight the correct answer button when the answer is wrong.
    @State private var highlightedCorrectAnswer: Int? = nil // Index in shuffledAnswerTexts
    // Új állapot változó a "Következő kérdés" gombhoz
    @State private var showNextButton = false
    
    // New state for shuffled answer texts
    @State private var shuffledAnswerTexts: [String] = []
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: backgroundGradient),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    // Top bar with settings button and questions remaining
                    HStack {
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.7))
                                .cornerRadius(10)
                        }
                        Spacer()
                        Text("Hátravan: \(viewModel.questions.count)")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
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
                            
                            // Use shuffledAnswerTexts for buttons
                            ForEach(shuffledAnswerTexts.indices, id: \.self) { index in
                                Button(action: { checkAnswer(selectedIndex: index) }) {
                                    Text(shuffledAnswerTexts[index]) // Display shuffled answer text
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        // Highlight based on index in shuffled list
                                        .background(highlightedCorrectAnswer == index ? Color.green : Color.gray.opacity(0.7))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .minimumScaleFactor(0.7)
                                }
                                .disabled(showFeedback)
                            }
                            
                            if showFeedback {
                                Spacer().frame(height: 10)
                            }
                            if showNextButton {
                                Button("Következő kérdés") {
                                    if answerFeedback == "Correct!" {
                                        viewModel.markCurrentQuestionAnsweredCorrectly()
                                    }
                                    withAnimation(.easeInOut) {
                                        showFeedback = false
                                        backgroundGradient = defaultGradient
                                        // highlightedCorrectAnswer is reset by shuffleAnswersForCurrentQuestion
                                        showNextButton = false
                                    }
                                    viewModel.getNextQuestion() // This will trigger shuffle via .onChange
                                }
                                // ... (rest of button styling)
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
                        // Shuffle answers when this view appears or when the question changes
                        .onAppear {
                            shuffleAnswersForCurrentQuestion()
                        }
                        // Assuming Question struct has an 'id' property or questionText is unique enough
                        // If Question is not Identifiable or Hashable, this might need adjustment
                        // Using questionText as a fallback if 'id' is not available or suitable
                        .onChange(of: question.questionText) { _ in
                            shuffleAnswersForCurrentQuestion()
                        }
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
            // Settings sheet
            if showSettings {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showSettings = false }
                VStack(spacing: 24) {
                    Text("Beállítások")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top)
                    // Category picker
                    Menu {
                        Button("All") {
                            selectedCategory = nil
                            viewModel.selectedCategory = nil
                            viewModel.loadQuestions()
                            viewModel.getNextQuestion()
                        }
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            Button("\(category.name)") {
                                selectedCategory = category
                                viewModel.selectedCategory = category
                                viewModel.loadQuestions()
                                viewModel.getNextQuestion()
                            }
                        }
                    } label: {
                        Label("Kategória: \(selectedCategory?.name ?? "All")",
                              systemImage: "line.horizontal.3.decrease.circle")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(10)
                    }
                    // Difficulty picker
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
                        Label("Nehézség: \(selectedDifficulty)",
                              systemImage: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(10)
                    }
                    // CSV fájl választó
                    Menu {
                        ForEach(viewModel.availableCSVFiles, id: \.self) { file in
                            Button(file) {
                                viewModel.selectedCSVFile = file
                                viewModel.loadQuestions()
                                // Frissítsük a UI-n a kategória kiválasztást is
                                self.selectedCategory = viewModel.selectedCategory
                                viewModel.getNextQuestion()
                            }
                        }
                    } label: {
                        Label("Kérdésfájl: \(viewModel.selectedCSVFile)", systemImage: "doc")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(10)
                    }
                    Button("Bezárás") {
                        showSettings = false
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom)
                }
                .frame(maxWidth: 350)
                .background(Color.black.opacity(0.95))
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding()
            }
        }
        .onAppear {
            viewModel.loadQuestions()
            viewModel.getNextQuestion()
            // Initial shuffle is handled by the .onAppear of the question's VStack
        }
    }
    
    // Removed getAnswerText(for: Question, index: Int)
    
    // Removed convertLetterToIndex(letter: String)

    // New function to shuffle answers for the current question
    private func shuffleAnswersForCurrentQuestion() {
        if let question = viewModel.currentQuestion {
            shuffledAnswerTexts = [question.answerA, question.answerB, question.answerC, question.answerD].shuffled()
            highlightedCorrectAnswer = nil // Reset highlight when question changes
        } else {
            shuffledAnswerTexts = []
        }
    }

    // New helper to get the text of the correct answer
    private func getCorrectAnswerText(for question: Question) -> String {
        switch question.correctAnswer {
        case "A": return question.answerA
        case "B": return question.answerB
        case "C": return question.answerC
        case "D": return question.answerD
        default: return "" // Should not happen with valid data
        }
    }
    
    private func checkAnswer(selectedIndex: Int) {
        guard let question = viewModel.currentQuestion, selectedIndex < shuffledAnswerTexts.count else { return }
        
        let selectedAnswerText = shuffledAnswerTexts[selectedIndex]
        let actualCorrectAnswerText = getCorrectAnswerText(for: question)
        
        withAnimation(.easeInOut) {
            if selectedAnswerText == actualCorrectAnswerText {
                backgroundGradient = [Color.green.opacity(0.5), Color.green]
                answerFeedback = "Correct!"
                highlightedCorrectAnswer = nil // No need to highlight if correct
            } else {
                backgroundGradient = [Color.red.opacity(0.5), Color.red]
                answerFeedback = "Wrong!"
                // Find the index of the actual correct answer in the shuffled list
                if let correctShuffledIndex = shuffledAnswerTexts.firstIndex(of: actualCorrectAnswerText) {
                    highlightedCorrectAnswer = correctShuffledIndex
                } else {
                    highlightedCorrectAnswer = nil // Should not happen if data is consistent
                }
            }
            showFeedback = true
            showNextButton = true
        }
        // Az automatikus továbblépés eltávolítva
    }
}
