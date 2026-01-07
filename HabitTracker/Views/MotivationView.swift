//
//  MotivationView.swift
//  HabitTracker
//
//  Экран с мотивационными цитатами
//

import SwiftUI

struct MotivationView: View {
    @State private var currentQuote = MotivationService.shared.quoteOfTheDay()
    @State private var showAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Цитата дня
                        quoteCard(quote: currentQuote)
                        
                        // Кнопка новой цитаты
                        Button(action: {
                            withAnimation {
                                showAnimation.toggle()
                            }
                            currentQuote = MotivationService.shared.randomQuote()
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Новая цитата")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        // Мотивационные советы
                        tipsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Мотивация")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func quoteCard(quote: MotivationalQuote) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.system(size: 40))
                .foregroundColor(.purple.opacity(0.6))
            
            Text(quote.text)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .scaleEffect(showAnimation ? 1.05 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showAnimation)
            
            if let author = quote.author {
                Text("— \(author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Советы для успеха")
                .font(.headline)
            
            TipCard(
                icon: "1.circle.fill",
                title: "Начните с малого",
                description: "Не пытайтесь изменить все сразу. Выберите 2-3 важные привычки."
            )
            
            TipCard(
                icon: "2.circle.fill",
                title: "Будьте последовательны",
                description: "Лучше делать что-то маленькое каждый день, чем большое раз в неделю."
            )
            
            TipCard(
                icon: "3.circle.fill",
                title: "Отслеживайте прогресс",
                description: "Используйте приложение для визуализации вашего прогресса."
            )
            
            TipCard(
                icon: "4.circle.fill",
                title: "Не сдавайтесь",
                description: "Если пропустили день, это не конец. Просто продолжите завтра."
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MotivationView()
}




