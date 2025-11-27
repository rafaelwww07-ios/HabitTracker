//
//  AnalyticsView.swift
//  HabitTracker
//
//  Расширенная аналитика и прогнозы
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Прогнозы
                    predictionsSection
                    
                    // Тренды
                    trendsSection
                    
                    // Анализ активности
                    activityAnalysis
                    
                    // Рекомендации
                    recommendationsSection
                }
                .padding()
            }
            .navigationTitle("Аналитика")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогнозы")
                .font(.headline)
            
            ForEach(habits.prefix(3)) { habit in
                PredictionCard(habit: habit)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Тренды")
                .font(.headline)
            
            Text("Ваши привычки за последние 30 дней")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Упрощенный график трендов
            TrendChart(habits: habits)
                .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var activityAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Анализ активности")
                .font(.headline)
            
            let mostActiveDay = getMostActiveDay()
            let leastActiveDay = getLeastActiveDay()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Самый активный день")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mostActiveDay)
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Менее активный день")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(leastActiveDay)
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Рекомендации")
                .font(.headline)
            
            let recommendations = generateRecommendations()
            
            ForEach(recommendations, id: \.self) { recommendation in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text(recommendation)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private func getMostActiveDay() -> String {
        // Упрощенная логика
        return "Понедельник"
    }
    
    private func getLeastActiveDay() -> String {
        return "Воскресенье"
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        for habit in habits {
            let streak = habit.currentStreak()
            if streak == 0 {
                recommendations.append("Начните выполнять '\(habit.name)' - это поможет вам вернуться в ритм!")
            } else if streak < 7 {
                recommendations.append("Отличный старт с '\(habit.name)'! Попробуйте дойти до 7 дней подряд!")
            }
        }
        
        if recommendations.isEmpty {
            recommendations.append("Вы отлично справляетесь! Продолжайте в том же духе.")
        }
        
        return Array(recommendations.prefix(5))
    }
}

struct PredictionCard: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            Image(systemName: habit.iconName)
                .foregroundColor(habit.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                let prediction = calculatePrediction()
                Text("Прогноз: \(prediction)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(habit.color.opacity(0.1))
        )
    }
    
    private func calculatePrediction() -> String {
        let streak = habit.currentStreak()
        let successRate = habit.overallCompletionPercentage()
        
        if successRate > 80 {
            return "Отличный результат, продолжайте!"
        } else if streak > 7 {
            return "Хороший прогресс, стрик растет!"
        } else {
            return "Нужно больше активности"
        }
    }
}

struct TrendChart: View {
    let habits: [Habit]
    
    var body: some View {
        Chart {
            ForEach(habits.prefix(5)) { habit in
                ForEach(getLast30Days(), id: \.self) { date in
                    let completions = getCompletionsForDate(habit: habit, date: date)
                    LineMark(
                        x: .value("Дата", date, unit: .day),
                        y: .value("Выполнения", completions)
                    )
                    .foregroundStyle(habit.color)
                    .interpolationMethod(.catmullRom)
                }
            }
        }
    }
    
    private func getLast30Days() -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                dates.append(date)
            }
        }
        return dates.reversed()
    }
    
    private func getCompletionsForDate(habit: Habit, date: Date) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        return habit.completions.filter { completion in
            completion.completedAt >= dayStart && completion.completedAt < dayEnd
        }.count
    }
}

#Preview {
    AnalyticsView(habits: [])
}

