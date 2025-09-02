//
//  MainTabView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NotesView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "note.text" : "note.text")
                    Text("Notes")
                }
                .tag(0)
            
            PlannerView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "calendar" : "calendar")
                    Text("Planner")
                }
                .tag(1)
            
            MiniGameView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gamecontroller.fill" : "gamecontroller")
                    Text("Game")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(AppColors.accent)
        .background(AppColors.mainBackground)
        .environmentObject(onboardingManager)
        .onAppear {
            configureTabBarAppearance()
        }
        .onChange(of: selectedTab) { newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                // Tab selection animation handled by the system
            }
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.secondaryBackground)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.secondaryText)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.secondaryText)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.accent)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(OnboardingManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}