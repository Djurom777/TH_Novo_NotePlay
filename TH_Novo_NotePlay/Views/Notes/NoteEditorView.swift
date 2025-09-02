//
//  NoteEditorView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct NoteEditorView: View {
    let note: Note?
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var noteBody: String
    @State private var showingDiscardAlert = false
    @FocusState private var titleFocused: Bool
    @FocusState private var bodyFocused: Bool
    
    private var isEditing: Bool {
        note != nil
    }
    
    private var hasChanges: Bool {
        if let note = note {
            return title != (note.title ?? "") || noteBody != (note.body ?? "")
        } else {
            return !title.isEmpty || !noteBody.isEmpty
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(note: Note?, onSave: @escaping (String, String) -> Void) {
        self.note = note
        self.onSave = onSave
        self._title = State(initialValue: note?.title ?? "")
        self._noteBody = State(initialValue: note?.body ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        TextField("Enter note title...", text: $title)
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
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Body Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(AppColors.secondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(bodyFocused ? AppColors.accent : Color.clear, lineWidth: 2)
                                )
                            
                            if noteBody.isEmpty {
                                Text("Start writing your note...")
                                    .foregroundColor(AppColors.secondaryText)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                            
                            TextEditor(text: $noteBody)
                                .foregroundColor(AppColors.primaryText)
                                .background(Color.clear)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .focused($bodyFocused)
                        }
                        .frame(minHeight: 200)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    Spacer()
                }
            }
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
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
                    onSave(title, noteBody)
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
    NoteEditorView(note: nil) { _, _ in }
}