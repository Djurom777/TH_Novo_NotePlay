//
//  DataSeeder.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import CoreData
import Foundation

class DataSeeder {
    static let shared = DataSeeder()
    private let context = PersistenceController.shared.container.viewContext
    
    private init() {}
    
    func seedInitialDataIfNeeded() {
        // No initial data seeding - app starts empty
    }
    
    private func hasExistingData() -> Bool {
        let noteRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let taskRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        
        do {
            let noteCount = try context.count(for: noteRequest)
            let taskCount = try context.count(for: taskRequest)
            return noteCount > 0 || taskCount > 0
        } catch {
            print("Error checking existing data: \(error)")
            return false
        }
    }
    
    private func seedSampleData() {
        // Create sample notes
        let note1 = Note(context: context)
        note1.id = UUID()
        note1.title = "Welcome to NotePlay Planner!"
        note1.body = "This is your first note. You can create, edit, and organize your thoughts here. Tap the + button to add new notes and use the search function to find them quickly."
        note1.createdAt = Date().addingTimeInterval(-86400) // 1 day ago
        note1.updatedAt = Date().addingTimeInterval(-86400)
        
        let note2 = Note(context: context)
        note2.id = UUID()
        note2.title = "Quick Tips"
        note2.body = "• Swipe left on any note to delete it\n• Use the search bar to find notes quickly\n• Check out the Planner tab to manage your tasks\n• Play the mini-game to take a break and challenge yourself!"
        note2.createdAt = Date().addingTimeInterval(-43200) // 12 hours ago
        note2.updatedAt = Date().addingTimeInterval(-43200)
        
        // Create sample task
        let task1 = TaskItem(context: context)
        task1.id = UUID()
        task1.title = "Explore NotePlay Planner"
        task1.dueDate = Date().addingTimeInterval(86400) // Tomorrow
        task1.isDone = false
        task1.notes = "Take some time to explore all the features of this app - Notes, Planner, Mini-Game, and Settings."
        
        // Create initial game progress
        let gameProgress = GameProgress(context: context)
        gameProgress.id = UUID()
        gameProgress.bestScore = 0
        gameProgress.lastPlayedAt = nil
        
        do {
            try context.save()
            print("Sample data seeded successfully")
        } catch {
            print("Failed to seed sample data: \(error)")
        }
    }
}