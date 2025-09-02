//
//  NotesViewModel.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import CoreData
import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let context = PersistenceController.shared.container.viewContext
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes.sorted { $0.updatedAt ?? Date.distantPast > $1.updatedAt ?? Date.distantPast }
        } else {
            return notes.filter { note in
                (note.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (note.body?.localizedCaseInsensitiveContains(searchText) ?? false)
            }.sorted { $0.updatedAt ?? Date.distantPast > $1.updatedAt ?? Date.distantPast }
        }
    }
    
    init() {
        fetchNotes()
    }
    
    func fetchNotes() {
        isLoading = true
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        
        do {
            notes = try context.fetch(request)
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch notes: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addNote(title: String, body: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Note title cannot be empty"
            return
        }
        
        let newNote = Note(context: context)
        newNote.id = UUID()
        newNote.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        newNote.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        
        saveContext()
    }
    
    func updateNote(_ note: Note, title: String, body: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Note title cannot be empty"
            return
        }
        
        note.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        note.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        note.updatedAt = Date()
        
        saveContext()
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchNotes()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save note: \(error.localizedDescription)"
        }
    }
}