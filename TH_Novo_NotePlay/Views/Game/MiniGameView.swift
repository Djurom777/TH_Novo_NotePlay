//
//  MiniGameView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct MiniGameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Game Header
                    GameHeaderView(viewModel: viewModel)
                    
                    if viewModel.gameState == .ready {
                        GameReadyView(viewModel: viewModel)
                    } else if viewModel.gameState == .playing {
                        GamePlayingView(viewModel: viewModel)
                    } else {
                        GameCompletedView(viewModel: viewModel)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Memory Match")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingTutorial = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingTutorial) {
                GameTutorialView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            configureNavigationAppearance()
        }
    }
    
    private func configureNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.mainBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.primaryText)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct GameHeaderView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            // Current Score
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                Text("\(viewModel.currentScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondaryBackground)
            )
            
            Spacer()
            
            // Moves
            VStack(alignment: .center, spacing: 4) {
                Text("Moves")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                Text("\(viewModel.moves)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondaryBackground)
            )
            
            Spacer()
            
            // Best Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("Best")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                Text("\(viewModel.bestScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondaryBackground)
            )
        }
    }
}

struct GameReadyView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            // Game Instructions
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 64))
                    .foregroundColor(AppColors.accent)
                
                Text("Memory Match")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Find matching pairs of cards to score points. Complete the game in fewer moves for bonus points!")
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            // Start Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.startGame()
                }
            }) {
                HStack {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    Image(systemName: "play.fill")
                        .foregroundColor(AppColors.primaryText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.accent)
                        .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
                )
            }
            .padding(.horizontal, 32)
        }
    }
}

struct GamePlayingView: View {
    @ObservedObject var viewModel: GameViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        VStack(spacing: 20) {
            // Game Grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.cards) { card in
                    GameCardView(card: card) {
                        viewModel.cardTapped(card)
                    }
                }
            }
            .padding(.horizontal, 8)
            
            // New Game Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.setupNewGame()
                }
            }) {
                Text("New Game")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.secondaryBackground)
                    )
            }
        }
    }
}

struct GameCompletedView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            // Completion Message
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppColors.secondaryButton)
                
                Text("Congratulations!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text("You completed the game in \(viewModel.moves) moves!")
                    .font(.title3)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                
                // Score Display
                VStack(spacing: 8) {
                    Text("Final Score")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("\(viewModel.currentScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.accent)
                    
                    if viewModel.currentScore == viewModel.bestScore {
                        Text("🎉 New Best Score! 🎉")
                            .font(.headline)
                            .foregroundColor(AppColors.secondaryButton)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.currentScore)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.secondaryBackground)
                )
            }
            
            // Play Again Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.setupNewGame()
                }
            }) {
                HStack {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppColors.primaryText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.primaryButton)
                        .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
                )
            }
            .padding(.horizontal, 32)
        }
    }
}

struct GameCardView: View {
    let card: GameCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.isMatched ? AppColors.accent.opacity(0.3) : AppColors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.isMatched ? AppColors.accent : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
                
                if card.isFlipped || card.isMatched {
                    Text(card.symbol)
                        .font(.system(size: 32))
                        .scaleEffect(card.isMatched ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: card.isMatched)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.primaryButton.opacity(0.8))
                        .frame(width: 40, height: 40)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .rotation3DEffect(
                .degrees(card.isFlipped || card.isMatched ? 0 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.3), value: card.isFlipped)
            .animation(.easeInOut(duration: 0.3), value: card.isMatched)
        }
        .disabled(card.isFlipped || card.isMatched)
    }
}

struct GameTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 64))
                                .foregroundColor(AppColors.accent)
                            
                            Text("How to Play")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 20) {
                            TutorialStepView(
                                number: "1",
                                title: "Find Matching Pairs",
                                description: "Tap cards to flip them over and reveal the symbols underneath."
                            )
                            
                            TutorialStepView(
                                number: "2",
                                title: "Remember Locations",
                                description: "Use your memory to remember where each symbol is located."
                            )
                            
                            TutorialStepView(
                                number: "3",
                                title: "Score Points",
                                description: "Each matched pair gives you 10 points. Complete in fewer moves for bonus points!"
                            )
                            
                            TutorialStepView(
                                number: "4",
                                title: "Beat Your Best",
                                description: "Try to achieve the highest score possible and beat your personal best!"
                            )
                        }
                        
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                    .font(.headline)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TutorialStepView: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step Number
            ZStack {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 32, height: 32)
                
                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MiniGameView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}