//
//  PersistenceController.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        let sampleNote = Note(context: viewContext)
        sampleNote.id = UUID()
        sampleNote.title = "Sample Note"
        sampleNote.body = "This is a sample note for preview"
        sampleNote.createdAt = Date()
        sampleNote.updatedAt = Date()
        
        let sampleTask = TaskItem(context: viewContext)
        sampleTask.id = UUID()
        sampleTask.title = "Sample Task"
        sampleTask.dueDate = Date().addingTimeInterval(86400)
        sampleTask.isDone = false
        sampleTask.notes = "Sample task notes"
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func deleteAllData() {
        let context = container.viewContext
        
        // Delete all entities
        let notesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let tasksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskItem")
        let gamesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "GameProgress")
        
        let deleteNotesRequest = NSBatchDeleteRequest(fetchRequest: notesFetch)
        let deleteTasksRequest = NSBatchDeleteRequest(fetchRequest: tasksFetch)
        let deleteGamesRequest = NSBatchDeleteRequest(fetchRequest: gamesFetch)
        
        do {
            try context.execute(deleteNotesRequest)
            try context.execute(deleteTasksRequest)
            try context.execute(deleteGamesRequest)
            try context.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
}