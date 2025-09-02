//
//  OnboardingView.swift
//  TH_Novo_NotePlay
//
//  Created by IGOR on 27/08/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var currentPage = 0
    private let totalPages = 3
    
    var body: some View {
        ZStack {
            AppColors.mainBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? AppColors.accent : AppColors.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Content
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        icon: "note.text",
                        title: "Capture Your Ideas",
                        subtitle: "Create and organize your thoughts with powerful note-taking features",
                        description: "Write, edit, and search through your notes with ease. Never lose a brilliant idea again."
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        icon: "calendar",
                        title: "Plan Your Day",
                        subtitle: "Stay organized with smart task management",
                        description: "Set due dates, add notes to tasks, and track your progress. Keep your life perfectly organized."
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        icon: "gamecontroller",
                        title: "Take a Break",
                        subtitle: "Challenge yourself with fun mini-games",
                        description: "Refresh your mind with engaging games. Track your best scores and compete with yourself."
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Navigation Buttons
                VStack(spacing: 16) {
                    if currentPage < totalPages - 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundColor(AppColors.primaryText)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(AppColors.primaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.primaryButton)
                                    .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 32)
                        
                        Button(action: {
                            onboardingManager.completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    } else {
                        Button(action: {
                            onboardingManager.completeOnboarding()
                        }) {
                            HStack {
                                Text("Get Started")
                                    .font(.headline)
                                    .foregroundColor(AppColors.primaryText)
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(AppColors.primaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.accent)
                                    .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 32)
                        .scaleEffect(1.05)
                        .animation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true), value: currentPage)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(AppColors.secondaryBackground)
                    .frame(width: 120, height: 120)
                    .shadow(color: AppColors.shadow, radius: 12, x: 0, y: 6)
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(AppColors.accent)
            }
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.6).delay(0.2), value: icon)
            
            // Text Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.accent)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(OnboardingManager())
}