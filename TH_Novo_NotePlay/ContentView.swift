//
//  ContentView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    
    var body: some View {
        Group {
            if onboardingManager.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark) // Fixed dark theme with your color palette
    }
}

#Preview {
    ContentView()
        .environmentObject(OnboardingManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
