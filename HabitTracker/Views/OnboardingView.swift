//
//  OnboardingView.swift
//  HabitTracker
//
//  Экран онбординга для новых пользователей
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Добро пожаловать!",
            description: "Начните свой путь к лучшей версии себя",
            icon: "sparkles",
            color: .blue
        ),
        OnboardingPage(
            title: "Отслеживайте привычки",
            description: "Создавайте привычки, отмечайте выполнение и следите за прогрессом",
            icon: "checkmark.circle.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Зарабатывайте баллы",
            description: "Получайте баллы за выполнение и повышайте свой уровень",
            icon: "star.fill",
            color: .yellow
        ),
        OnboardingPage(
            title: "Достигайте целей",
            description: "Участвуйте в челленджах и разблокируйте достижения",
            icon: "trophy.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            isPresented = false
                        }) {
                            Text("Начать")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Далее")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

