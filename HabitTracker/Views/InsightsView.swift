//
//  InsightsView.swift
//  HabitTracker
//
//  Экран с инсайтами и рекомендациями
//

import SwiftUI

struct InsightsView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Главный инсайт
                    mainInsight
                    
                    // Рекомендации
                    recommendations
                    
                    // Паттерны
                    patterns
                    
                    // Прогнозы
                    predictions
                }
                .padding()
            }
            .navigationTitle("Инсайты")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var mainInsight: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Главный инсайт")
                    .font(.headline)
            }
            
            let insight = generateMainInsight()
            
            Text(insight)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Рекомендации")
                .font(.headline)
            
            ForEach(generateRecommendations().prefix(5), id: \.self) { recommendation in
                InsightCard(
                    icon: "star.fill",
                    title: recommendation,
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var patterns: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Паттерны")
                .font(.headline)
            
            ForEach(detectPatterns().prefix(3), id: \.self) { pattern in
                InsightCard(
                    icon: "waveform.path",
                    title: pattern,
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var predictions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогнозы")
                .font(.headline)
            
            ForEach(generatePredictions().prefix(3), id: \.self) { prediction in
                InsightCard(
                    icon: "crystal.ball.fill",
                    title: prediction,
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private func generateMainInsight() -> String {
        guard !habits.isEmpty else {
            return "Начните отслеживать привычки, чтобы получить персональные инсайты!"
        }
        
        let totalStreak = habits.reduce(0) { $0 + $1.currentStreak() }
        let averageStreak = Double(totalStreak) / Double(habits.count)
        
        if averageStreak >= 7 {
            return "🎉 Отличная работа! Вы поддерживаете средний стрик \(Int(averageStreak)) дней. Это показывает высокий уровень дисциплины!"
        } else if averageStreak >= 3 {
            return "Вы на правильном пути! Средний стрик \(Int(averageStreak)) дней - хорошее начало. Попробуйте довести его до недели."
        } else {
            return "Начните регулярно отслеживать привычки, чтобы увидеть реальный прогресс. Небольшие шаги каждый день приведут к большим результатам!"
        }
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        for habit in habits {
            let streak = habit.currentStreak()
            let successRate = habit.overallCompletionPercentage()
            
            if streak == 0 && successRate < 50 {
                recommendations.append("Попробуйте установить напоминание для \"\(habit.name)\" - это поможет не забывать о привычке")
            } else if successRate < 70 {
                recommendations.append("Для \"\(habit.name)\" попробуйте снизить цель или выбрать более реалистичное время выполнения")
            } else if streak >= 7 {
                recommendations.append("\"\(habit.name)\" идет отлично! Подумайте о добавлении новой связанной привычки")
            }
        }
        
        if recommendations.isEmpty {
            recommendations.append("Отличная работа! Продолжайте в том же духе")
        }
        
        return recommendations
    }
    
    private func detectPatterns() -> [String] {
        var patterns: [String] = []
        
        let calendar = Calendar.current
        var weekdayCompletions: [Int: Int] = [:]
        
        for habit in habits {
            for completion in habit.completions {
                let weekday = calendar.component(.weekday, from: completion.completedAt)
                weekdayCompletions[weekday, default: 0] += 1
            }
        }
        
        if let mostActiveDay = weekdayCompletions.max(by: { $0.value < $1.value }) {
            let dayNames = ["", "Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
            patterns.append("Вы наиболее активны в \(dayNames[mostActiveDay.key] ?? "неизвестный день")")
        }
        
        let morningCompletions = habits.flatMap { $0.completions }.filter { completion in
            let hour = calendar.component(.hour, from: completion.completedAt)
            return hour < 12
        }.count
        
        let totalCompletions = habits.reduce(0) { $0 + $1.completions.count }
        if totalCompletions > 0 {
            let morningPercentage = Double(morningCompletions) / Double(totalCompletions) * 100
            if morningPercentage > 60 {
                patterns.append("Вы предпочитаете выполнять привычки утром (\(Int(morningPercentage))%)")
            } else if morningPercentage < 30 {
                patterns.append("Большинство ваших привычек выполняется вечером (\(Int(100 - morningPercentage))%)")
            }
        }
        
        return patterns
    }
    
    private func generatePredictions() -> [String] {
        var predictions: [String] = []
        
        for habit in habits {
            let streak = habit.currentStreak()
            let successRate = habit.overallCompletionPercentage()
            
            if streak >= 3 && successRate > 75 {
                predictions.append("При текущем темпе, \"\(habit.name)\" достигнет 30-дневного стрика через \(max(1, 30 - streak)) дней")
            }
        }
        
        if predictions.isEmpty {
            predictions.append("Продолжайте отслеживать привычки для получения прогнозов")
        }
        
        return predictions
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    InsightsView(habits: [])
}

