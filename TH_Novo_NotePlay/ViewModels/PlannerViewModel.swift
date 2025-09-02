//
//  PlannerViewModel.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import CoreData
import Foundation

class PlannerViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var viewMode: ViewMode = .list
    
    enum ViewMode {
        case list, calendar
    }
    
    private let context = PersistenceController.shared.container.viewContext
    
    var tasksForSelectedDate: [TaskItem] {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }.sorted { task1, task2 in
            guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
            return date1 < date2
        }
    }
    
    var upcomingTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return !task.isDone && dueDate >= calendar.startOfDay(for: today)
        }.sorted { task1, task2 in
            guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
            return date1 < date2
        }
    }
    
    var completedTasks: [TaskItem] {
        return tasks.filter { $0.isDone }
            .sorted { task1, task2 in
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
                return date1 > date2
            }
    }
    
    init() {
        fetchTasks()
    }
    
    func fetchTasks() {
        isLoading = true
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)]
        
        do {
            tasks = try context.fetch(request)
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addTask(title: String, dueDate: Date?, notes: String?) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Task title cannot be empty"
            return
        }
        
        let newTask = TaskItem(context: context)
        newTask.id = UUID()
        newTask.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        newTask.dueDate = dueDate
        newTask.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        newTask.isDone = false
        
        saveContext()
    }
    
    func updateTask(_ task: TaskItem, title: String, dueDate: Date?, notes: String?) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Task title cannot be empty"
            return
        }
        
        task.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.dueDate = dueDate
        task.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        saveContext()
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isDone.toggle()
        saveContext()
    }
    
    func deleteTask(_ task: TaskItem) {
        context.delete(task)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
        }
    }
}