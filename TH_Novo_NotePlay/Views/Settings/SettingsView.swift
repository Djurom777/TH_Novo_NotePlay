//
//  SettingsView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var showingDeleteAlert = false

    @State private var isDeleting = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.mainBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {

                        
                        // Data Management Section
                        SettingsSectionView(title: "Data Management") {
                            SettingsRowView(
                                icon: "trash.fill",
                                title: "Delete All Data",
                                subtitle: "Remove all app data",
                                isDestructive: true
                            ) {
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    if isDeleting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(AppColors.primaryButton)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                }
                                .disabled(isDeleting)
                            }
                        }
                        

                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete All Data?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your notes, tasks, and game progress. This action cannot be undone.")
            }

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            configureNavigationAppearance()
        }
    }
    
    private func deleteAllData() {
        isDeleting = true
        
        // Add a small delay to show the loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Delete all data
            PersistenceController.shared.deleteAllData()
            
            // Reset onboarding
            onboardingManager.resetOnboarding()
            
            // Theme is fixed to dark mode - no reset needed
            
            isDeleting = false
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

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.secondaryBackground)
            )
        }
    }
}

struct SettingsRowView<Accessory: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    let isDestructive: Bool
    let accessory: Accessory
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isDestructive: Bool = false,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = isDestructive
        self.accessory = accessory()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDestructive ? AppColors.primaryButton : AppColors.accent)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? AppColors.primaryButton : AppColors.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            Spacer()
            
            // Accessory
            accessory
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}



#Preview {
    SettingsView()
        .environmentObject(OnboardingManager())
}