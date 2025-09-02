//
//  OnboardingManager.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import Foundation

class OnboardingManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.removeObject(forKey: onboardingKey)
    }
}