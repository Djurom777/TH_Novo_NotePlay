//
//  TH_Novo_NotePlayApp.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

@main
struct TH_Novo_NotePlayApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(onboardingManager)
        }
    }
}
