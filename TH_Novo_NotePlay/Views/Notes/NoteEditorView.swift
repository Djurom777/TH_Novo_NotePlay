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
    
    @State private var title: String = ""
    @State private var content: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool
    @FocusState private var bodyFocused: Bool
    
    var isEditing: Bool {
        note != nil
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
                            Text("Note Title")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            TextField("Enter note title...", text: $title)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.title2)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(minHeight: 50)
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
                        
                        // Body Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note Content")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.secondaryBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(bodyFocused ? AppColors.accent : Color.clear, lineWidth: 2)
                                    )
                                
                                if content.isEmpty {
                                    Text("Start writing your note...")
                                        .foregroundColor(AppColors.secondaryText)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $content)
                                    .foregroundColor(AppColors.primaryText)
                                    .background(Color.clear)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .focused($bodyFocused)
                            }
                            .frame(minHeight: 200)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.secondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), 
                               content.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                    .font(.headline)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let note = note {
                title = note.title ?? ""
                content = note.body ?? ""
            }
            
            // Focus title field for new notes
            if !isEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    titleFocused = true
                }
            }
        }
        // Ensure proper scaling for compatibility mode
        .scaleEffect(1.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoteEditorView(note: nil) { title, content in
        print("Saving: \(title) - \(content)")
    }
}