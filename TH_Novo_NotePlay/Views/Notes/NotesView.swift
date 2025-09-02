//
//  NotesView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    @State private var selectedNote: Note?
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                            .foregroundColor(AppColors.accent)
                        Spacer()
                    } else if viewModel.filteredNotes.isEmpty {
                        EmptyNotesView(hasSearchText: !viewModel.searchText.isEmpty)
                    } else {
                        // Notes List
                        List {
                            ForEach(viewModel.filteredNotes, id: \.id) { note in
                                NoteRowView(note: note)
                                    .onTapGesture {
                                        selectedNote = note
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                viewModel.deleteNote(note)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                        .refreshable {
                            viewModel.fetchNotes()
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                NoteEditorView(note: nil) { title, body in
                    viewModel.addNote(title: title, body: body)
                }
            }
            .sheet(item: $selectedNote) { note in
                NoteEditorView(note: note) { title, body in
                    viewModel.updateNote(note, title: title, body: body)
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

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.secondaryText)
            
            TextField("Search notes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(AppColors.primaryText)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.secondaryBackground)
        )
    }
}

struct NoteRowView: View {
    let note: Note
    
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: note.updatedAt ?? Date(), relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title ?? "Untitled")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if let body = note.body, !body.isEmpty {
                Text(body)
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.secondaryBackground)
                .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct EmptyNotesView: View {
    let hasSearchText: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: hasSearchText ? "magnifyingglass" : "note.text")
                .font(.system(size: 64))
                .foregroundColor(AppColors.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(hasSearchText ? "No Results Found" : "No Notes Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                Text(hasSearchText ? "Try adjusting your search terms" : "Tap the + button to create your first note")
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    NotesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}