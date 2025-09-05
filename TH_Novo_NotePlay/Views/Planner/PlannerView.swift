//
//  PlannerView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct PlannerView: View {
    @StateObject private var viewModel = PlannerViewModel()
    @State private var showingAddTask = false
    @State private var selectedTask: TaskItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // View Mode Picker
                    Picker("View Mode", selection: $viewModel.viewMode) {
                        Text("List").tag(PlannerViewModel.ViewMode.list)
                        Text("Calendar").tag(PlannerViewModel.ViewMode.calendar)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                            .foregroundColor(AppColors.accent)
                        Spacer()
                    } else {
                        if viewModel.viewMode == .calendar {
                            CalendarView(viewModel: viewModel, selectedTask: $selectedTask)
                        } else {
                            TaskListView(viewModel: viewModel, selectedTask: $selectedTask)
                        }
                    }
                }
            }
            .navigationTitle("Planner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskEditorView(task: nil) { title, dueDate, notes in
                    viewModel.addTask(title: title, dueDate: dueDate, notes: notes)
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskEditorView(task: task) { title, dueDate, notes in
                    viewModel.updateTask(task, title: title, dueDate: dueDate, notes: notes)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
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

struct TaskListView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @Binding var selectedTask: TaskItem?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !viewModel.upcomingTasks.isEmpty {
                    TaskSectionView(
                        title: "Upcoming",
                        tasks: viewModel.upcomingTasks,
                        viewModel: viewModel,
                        selectedTask: $selectedTask
                    )
                }
                
                if !viewModel.completedTasks.isEmpty {
                    TaskSectionView(
                        title: "Completed",
                        tasks: viewModel.completedTasks,
                        viewModel: viewModel,
                        selectedTask: $selectedTask
                    )
                }
                
                if viewModel.upcomingTasks.isEmpty && viewModel.completedTasks.isEmpty {
                    EmptyTasksView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            viewModel.fetchTasks()
        }
    }
}

struct CalendarView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @Binding var selectedTask: TaskItem?
    
    var body: some View {
        VStack(spacing: 16) {
            // Date Picker
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .accentColor(AppColors.accent)
            .padding(.horizontal, 16)
            
            // Tasks for Selected Date
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tasks for \(viewModel.selectedDate, style: .date)")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                if viewModel.tasksForSelectedDate.isEmpty {
                    Text("No tasks for this date")
                        .font(.body)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 32)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.tasksForSelectedDate, id: \.id) { task in
                            TaskRowView(
                                task: task,
                                viewModel: viewModel,
                                selectedTask: $selectedTask
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()
        }
        .padding(.top, 16)
    }
}

struct TaskSectionView: View {
    let title: String
    let tasks: [TaskItem]
    @ObservedObject var viewModel: PlannerViewModel
    @Binding var selectedTask: TaskItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.secondaryBackground)
                    )
            }
            
            LazyVStack(spacing: 8) {
                ForEach(tasks, id: \.id) { task in
                    TaskRowView(
                        task: task,
                        viewModel: viewModel,
                        selectedTask: $selectedTask
                    )
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: TaskItem
    @ObservedObject var viewModel: PlannerViewModel
    @Binding var selectedTask: TaskItem?
    
    private var formattedDate: String {
        guard let dueDate = task.dueDate else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    private var isOverdue: Bool {
        guard let dueDate = task.dueDate else { return false }
        return !task.isDone && dueDate < Date()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.toggleTaskCompletion(task)
                }
            }) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isDone ? AppColors.accent : AppColors.secondaryText)
            }
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Untitled Task")
                    .font(.headline)
                    .foregroundColor(task.isDone ? AppColors.secondaryText : AppColors.primaryText)
                    .strikethrough(task.isDone)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(isOverdue ? AppColors.primaryButton : AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(minHeight: 70) // Ensure minimum height for proper text display
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(task.isDone ? AppColors.secondaryBackground.opacity(0.6) : AppColors.secondaryBackground)
                .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            selectedTask = task
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.deleteTask(task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar")
                .font(.system(size: 64))
                .foregroundColor(AppColors.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Tasks Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Tap the + button to create your first task")
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 64)
    }
}

#Preview {
    PlannerView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}