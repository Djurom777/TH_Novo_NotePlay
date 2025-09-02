//
//  GameViewModel.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import CoreData
import Foundation

class GameViewModel: ObservableObject {
    @Published var cards: [GameCard] = []
    @Published var currentScore = 0
    @Published var bestScore = 0
    @Published var moves = 0
    @Published var isGameActive = false
    @Published var gameState: GameState = .ready
    @Published var showingTutorial = false
    
    enum GameState {
        case ready, playing, completed
    }
    
    private var flippedCards: [GameCard] = []
    private let context = PersistenceController.shared.container.viewContext
    private let cardSymbols = ["🎮", "🎯", "🎲", "🎪", "🎨", "🎭", "🎪", "🎊"]
    
    init() {
        loadBestScore()
        setupNewGame()
    }
    
    func setupNewGame() {
        gameState = .ready
        currentScore = 0
        moves = 0
        isGameActive = false
        flippedCards.removeAll()
        createCards()
    }
    
    func startGame() {
        gameState = .playing
        isGameActive = true
        currentScore = 0
        moves = 0
    }
    
    func cardTapped(_ card: GameCard) {
        guard isGameActive && !card.isMatched && !card.isFlipped else { return }
        
        // Flip the card
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFlipped = true
            flippedCards.append(cards[index])
            
            if flippedCards.count == 2 {
                moves += 1
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard flippedCards.count == 2 else { return }
        
        let card1 = flippedCards[0]
        let card2 = flippedCards[1]
        
        if card1.symbol == card2.symbol {
            // Match found
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.markCardsAsMatched(card1, card2)
                self.currentScore += 10
                self.flippedCards.removeAll()
                self.checkGameCompletion()
            }
        } else {
            // No match
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCardsBack(card1, card2)
                self.flippedCards.removeAll()
            }
        }
    }
    
    private func markCardsAsMatched(_ card1: GameCard, _ card2: GameCard) {
        if let index1 = cards.firstIndex(where: { $0.id == card1.id }) {
            cards[index1].isMatched = true
        }
        if let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
            cards[index2].isMatched = true
        }
    }
    
    private func flipCardsBack(_ card1: GameCard, _ card2: GameCard) {
        if let index1 = cards.firstIndex(where: { $0.id == card1.id }) {
            cards[index1].isFlipped = false
        }
        if let index2 = cards.firstIndex(where: { $0.id == card2.id }) {
            cards[index2].isFlipped = false
        }
    }
    
    private func checkGameCompletion() {
        if cards.allSatisfy({ $0.isMatched }) {
            gameState = .completed
            isGameActive = false
            
            // Calculate final score (bonus for fewer moves)
            let moveBonus = max(0, 50 - moves)
            currentScore += moveBonus
            
            if currentScore > bestScore {
                bestScore = currentScore
                saveBestScore()
            }
        }
    }
    
    private func createCards() {
        var newCards: [GameCard] = []
        
        // Create pairs of cards
        for (index, symbol) in cardSymbols.enumerated() {
            newCards.append(GameCard(id: UUID(), symbol: symbol, pairId: index))
            newCards.append(GameCard(id: UUID(), symbol: symbol, pairId: index))
        }
        
        // Shuffle the cards
        cards = newCards.shuffled()
    }
    
    private func loadBestScore() {
        let request: NSFetchRequest<GameProgress> = GameProgress.fetchRequest()
        
        do {
            let gameProgress = try context.fetch(request).first
            bestScore = Int(gameProgress?.bestScore ?? 0)
        } catch {
            print("Failed to load best score: \(error)")
        }
    }
    
    private func saveBestScore() {
        let request: NSFetchRequest<GameProgress> = GameProgress.fetchRequest()
        
        do {
            let gameProgress = try context.fetch(request).first ?? GameProgress(context: context)
            gameProgress.bestScore = Int32(bestScore)
            gameProgress.lastPlayedAt = Date()
            if gameProgress.id == nil {
                gameProgress.id = UUID()
            }
            
            try context.save()
        } catch {
            print("Failed to save best score: \(error)")
        }
    }
}

struct GameCard: Identifiable, Equatable {
    let id: UUID
    let symbol: String
    let pairId: Int
    var isFlipped = false
    var isMatched = false
    
    static func == (lhs: GameCard, rhs: GameCard) -> Bool {
        lhs.id == rhs.id
    }
}