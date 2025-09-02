//
//  TaskEditorView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct TaskEditorView: View {
    let task: TaskItem?
    let onSave: (String, Date?, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var notes: String
    @State private var showingDiscardAlert = false
    @FocusState private var titleFocused: Bool
    
    private var isEditing: Bool {
        task != nil
    }
    
    private var hasChanges: Bool {
        if let task = task {
            let originalHasDueDate = task.dueDate != nil
            let originalDate = task.dueDate ?? Date()
            return title != (task.title ?? "") ||
                   notes != (task.notes ?? "") ||
                   hasDueDate != originalHasDueDate ||
                   (hasDueDate && !Calendar.current.isDate(dueDate, equalTo: originalDate, toGranularity: .minute))
        } else {
            return !title.isEmpty || !notes.isEmpty || hasDueDate
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(task: TaskItem?, onSave: @escaping (String, Date?, String?) -> Void) {
        self.task = task
        self.onSave = onSave
        self._title = State(initialValue: task?.title ?? "")
        self._notes = State(initialValue: task?.notes ?? "")
        self._hasDueDate = State(initialValue: task?.dueDate != nil)
        self._dueDate = State(initialValue: task?.dueDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            TextField("Enter task title...", text: $title)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.title2)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(AppColors.secondaryBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(titleFocused ? AppColors.accent : Color.clear, lineWidth: 2)
                                        )
                                )
                                .focused($titleFocused)
                        }
                        
                        // Due Date Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Due Date")
                                    .font(.headline)
                                    .foregroundColor(AppColors.primaryText)
                                
                                Spacer()
                                
                                Toggle("", isOn: $hasDueDate)
                                    .toggleStyle(SwitchToggleStyle(tint: AppColors.accent))
                            }
                            
                            if hasDueDate {
                                DatePicker(
                                    "Due Date",
                                    selection: $dueDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(WheelDatePickerStyle())
                                .accentColor(AppColors.accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.secondaryBackground)
                                )
                            }
                        }
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.secondaryBackground)
                                
                                if notes.isEmpty {
                                    Text("Add additional notes...")
                                        .foregroundColor(AppColors.secondaryText)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $notes)
                                    .foregroundColor(AppColors.primaryText)
                                    .background(Color.clear)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            .frame(minHeight: 120)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    if hasChanges {
                        showingDiscardAlert = true
                    } else {
                        dismiss()
                    }
                }
                .foregroundColor(AppColors.secondaryText),
                
                trailing: Button("Save") {
                    let finalDueDate = hasDueDate ? dueDate : nil
                    let finalNotes = notes.isEmpty ? nil : notes
                    onSave(title, finalDueDate, finalNotes)
                    dismiss()
                }
                .foregroundColor(canSave ? AppColors.accent : AppColors.secondaryText)
                .disabled(!canSave)
                .font(.headline)
            )
            .onAppear {
                configureNavigationAppearance()
                if !isEditing {
                    titleFocused = true
                }
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func configureNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.mainBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.primaryText)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    TaskEditorView(task: nil) { _, _, _ in }
}