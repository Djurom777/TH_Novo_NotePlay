//
//  MiniGameView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct MiniGameView: View {
    @State private var selectedGame = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Game Selection
                    Picker("Game Type", selection: $selectedGame) {
                        Text("Card Match").tag(0)
                        Text("Word Puzzle").tag(1)
                        Text("Number Game").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    
                    // Game Content
                    Group {
                        switch selectedGame {
                        case 0:
                            CardMatchGameView()
                        case 1:
                            WordPuzzleGameView()
                        case 2:
                            NumberGameView()
                        default:
                            CardMatchGameView()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 16)
            }
            .navigationTitle("Brain Games")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CardMatchGameView: View {
    @State private var cards: [GameCard] = []
    @State private var flippedCards: [Int] = []
    @State private var matchedCards: [Int] = []
    @State private var score = 0
    @State private var moves = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Score Display
            HStack {
                Text("Score: \(score)")
                Spacer()
                Text("Moves: \(moves)")
            }
            .font(.headline)
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, 16)
            
            // Game Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(0..<cards.count, id: \.self) { index in
                    CardView(
                        card: cards[index],
                        isFlipped: flippedCards.contains(index) || matchedCards.contains(index),
                        isMatched: matchedCards.contains(index)
                    ) {
                        cardTapped(at: index)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Reset Button
            Button("New Game") {
                resetGame()
            }
            .font(.headline)
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.accent)
            )
        }
        .onAppear {
            resetGame()
        }
    }
    
    private func resetGame() {
        let symbols = ["🌟", "🎵", "🎨", "📚", "⚡️", "🌙", "🔥", "💎"]
        let gameSymbols = symbols + symbols // Duplicate for pairs
        cards = gameSymbols.shuffled().map { GameCard(symbol: $0) }
        flippedCards = []
        matchedCards = []
        score = 0
        moves = 0
    }
    
    private func cardTapped(at index: Int) {
        guard !matchedCards.contains(index) && !flippedCards.contains(index) && flippedCards.count < 2 else {
            return
        }
        
        flippedCards.append(index)
        
        if flippedCards.count == 2 {
            moves += 1
            let firstIndex = flippedCards[0]
            let secondIndex = flippedCards[1]
            
            if cards[firstIndex].symbol == cards[secondIndex].symbol {
                // Match found
                matchedCards.append(contentsOf: flippedCards)
                score += 10
                flippedCards = []
                
                // Check if game is complete
                if matchedCards.count == cards.count {
                    // Game completed
                    score += max(0, 100 - moves * 2) // Bonus for fewer moves
                }
            } else {
                // No match, flip back after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    flippedCards = []
                }
            }
        }
    }
}

struct CardView: View {
    let card: GameCard
    let isFlipped: Bool
    let isMatched: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isMatched ? AppColors.accent.opacity(0.3) : AppColors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFlipped ? AppColors.accent : Color.clear, lineWidth: 2)
                    )
                    .frame(height: 80)
                
                if isFlipped {
                    Text(card.symbol)
                        .font(.title)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.accent.opacity(0.8))
                        .frame(width: 40, height: 40)
                }
            }
        }
        .disabled(isFlipped && !isMatched)
        .scaleEffect(isFlipped ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFlipped)
    }
}

struct WordPuzzleGameView: View {
    @State private var currentWord = ""
    @State private var scrambledWord = ""
    @State private var userInput = ""
    @State private var score = 0
    @State private var attempts = 0
    @State private var showingResult = false
    @State private var resultMessage = ""
    @State private var isCorrect = false
    
    private let words = ["SWIFT", "PUZZLE", "BRAIN", "LOGIC", "THINK", "SOLVE", "SMART", "LEARN", "FOCUS", "MIND"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Score Display
            HStack {
                Text("Score: \(score)")
                Spacer()
                Text("Attempts: \(attempts)")
            }
            .font(.headline)
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, 16)
            
            // Game Content
            VStack(spacing: 20) {
                Text("Unscramble the word:")
                    .font(.title3)
                    .foregroundColor(AppColors.primaryText)
                
                // Scrambled word display
                Text(scrambledWord)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.secondaryBackground)
                    )
                
                // Input field
                TextField("Enter your guess...", text: $userInput)
                    .font(.title2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Submit") {
                        checkAnswer()
                    }
                    .buttonStyle(GameButtonStyle(color: AppColors.accent))
                    .disabled(userInput.isEmpty)
                    
                    Button("Skip") {
                        skipWord()
                    }
                    .buttonStyle(GameButtonStyle(color: AppColors.secondaryText))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.secondaryBackground.opacity(0.3))
            )
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .alert("Result", isPresented: $showingResult) {
            Button("Next Word") {
                nextWord()
            }
        } message: {
            Text(resultMessage)
        }
        .onAppear {
            nextWord()
        }
    }
    
    private func checkAnswer() {
        attempts += 1
        if userInput.uppercased() == currentWord {
            score += 10
            isCorrect = true
            resultMessage = "Correct! Well done! 🎉"
        } else {
            isCorrect = false
            resultMessage = "Wrong! The word was: \(currentWord)"
        }
        showingResult = true
    }
    
    private func skipWord() {
        attempts += 1
        isCorrect = false
        resultMessage = "Skipped! The word was: \(currentWord)"
        showingResult = true
    }
    
    private func nextWord() {
        currentWord = words.randomElement() ?? "SWIFT"
        scrambledWord = String(currentWord.shuffled())
        
        // Make sure scrambled word is different from original
        while scrambledWord == currentWord {
            scrambledWord = String(currentWord.shuffled())
        }
        
        userInput = ""
    }
}

struct NumberGameView: View {
    @State private var currentProblem = MathProblem(num1: 0, num2: 0, operation: "+", answer: 0)
    @State private var userAnswer = ""
    @State private var score = 0
    @State private var streak = 0
    @State private var timeLeft = 30
    @State private var gameActive = false
    @State private var showingResult = false
    @State private var resultMessage = ""
    @State private var isCorrect = false
    
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 24) {
            // Score and Timer Display
            HStack {
                VStack(alignment: .leading) {
                    Text("Score: \(score)")
                    Text("Streak: \(streak)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Time: \(timeLeft)s")
                        .foregroundColor(timeLeft <= 10 ? .red : AppColors.primaryText)
                    Text(gameActive ? "Playing" : "Ready")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .font(.headline)
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, 16)
            
            // Game Content
            VStack(spacing: 20) {
                if gameActive {
                    // Math problem display
                    Text("\(currentProblem.num1) \(currentProblem.operation) \(currentProblem.num2) = ?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.secondaryBackground)
                        )
                    
                    // Answer input
                    TextField("Your answer", text: $userAnswer)
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                    
                    // Submit button
                    Button("Submit") {
                        checkAnswer()
                    }
                    .buttonStyle(GameButtonStyle(color: AppColors.accent))
                    .disabled(userAnswer.isEmpty)
                } else {
                    // Start game screen
                    VStack(spacing: 16) {
                        Text("Math Challenge")
                            .font(.title2)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Solve as many math problems as you can in 30 seconds!")
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        Button("Start Game") {
                            startGame()
                        }
                        .buttonStyle(GameButtonStyle(color: AppColors.accent))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.secondaryBackground.opacity(0.3))
            )
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .alert("Time's Up!", isPresented: $showingResult) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("Final Score: \(score)\nBest Streak: \(streak)")
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startGame() {
        gameActive = true
        score = 0
        streak = 0
        timeLeft = 30
        generateNewProblem()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeLeft -= 1
            if timeLeft <= 0 {
                endGame()
            }
        }
    }
    
    private func endGame() {
        gameActive = false
        timer?.invalidate()
        showingResult = true
    }
    
    private func resetGame() {
        gameActive = false
        score = 0
        streak = 0
        timeLeft = 30
        userAnswer = ""
    }
    
    private func checkAnswer() {
        if let answer = Int(userAnswer), answer == currentProblem.answer {
            score += (streak >= 5 ? 15 : 10) // Bonus for streaks
            streak += 1
        } else {
            streak = 0
        }
        
        userAnswer = ""
        generateNewProblem()
    }
    
    private func generateNewProblem() {
        let operations = ["+", "-", "×"]
        let operation = operations.randomElement() ?? "+"
        
        let num1 = Int.random(in: 1...20)
        let num2 = Int.random(in: 1...20)
        
        let answer: Int
        switch operation {
        case "+":
            answer = num1 + num2
        case "-":
            // Ensure positive result
            let larger = max(num1, num2)
            let smaller = min(num1, num2)
            answer = larger - smaller
            currentProblem = MathProblem(num1: larger, num2: smaller, operation: operation, answer: answer)
            return
        case "×":
            answer = num1 * num2
        default:
            answer = num1 + num2
        }
        
        currentProblem = MathProblem(num1: num1, num2: num2, operation: operation, answer: answer)
    }
}

struct GameCard {
    let symbol: String
}

struct MathProblem {
    let num1: Int
    let num2: Int
    let operation: String
    let answer: Int
}

struct GameButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    MiniGameView()
}