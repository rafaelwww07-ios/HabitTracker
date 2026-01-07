//
//  StreakAnimationView.swift
//  HabitTracker
//
//  Анимация стрика для мотивации
//

import SwiftUI

struct StreakAnimationView: View {
    let streak: Int
    let color: Color
    @State private var animate = false
    @State private var showCongratulations = false
    
    var body: some View {
        ZStack {
            if showCongratulations {
                congratulationsOverlay
            }
        }
        .onChange(of: streak) { newValue in
            if newValue > 0 && (newValue == 7 || newValue == 30 || newValue == 90 || newValue % 10 == 0) {
                triggerCongratulations()
            }
        }
    }
    
    private var congratulationsOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .scaleEffect(animate ? 1.2 : 0.8)
                .rotationEffect(.degrees(animate ? 10 : -10))
            
            Text("🎉 Поздравляем!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(streak) дней подряд!")
                .font(.title2)
                .foregroundColor(color)
            
            if streak >= 7 {
                Text(getAchievementMessage(for: streak))
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 20)
        )
        .scaleEffect(animate ? 1.0 : 0.5)
        .opacity(animate ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
    }
    
    private func triggerCongratulations() {
        withAnimation {
            showCongratulations = true
            animate = true
        }
        
        // Скрываем через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                animate = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCongratulations = false
            }
        }
    }
    
    private func getAchievementMessage(for streak: Int) -> String {
        switch streak {
        case 7:
            return "Отличное начало! Вы держите стрик неделю!"
        case 30:
            return "Невероятно! Целый месяц подряд!"
        case 90:
            return "Потрясающе! 90 дней - это настоящая привычка!"
        default:
            if streak % 10 == 0 {
                return "\(streak) дней подряд - вы на пути к успеху!"
            }
            return "Продолжайте в том же духе!"
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        
        StreakAnimationView(streak: 7, color: .blue)
    }
}




