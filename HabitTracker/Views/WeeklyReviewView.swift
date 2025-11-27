//
//  WeeklyReviewView.swift
//  HabitTracker
//
//  Еженедельный обзор прогресса
//

import SwiftUI

struct WeeklyReviewView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Обзор недели
                    weekOverview
                    
                    // Улучшения
                    improvements
                    
                    // Что можно улучшить
                    whatToImprove
                    
                    // Награда
                    reward
                }
                .padding()
            }
            .navigationTitle("Недельный обзор")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var weekOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Обзор недели")
                .font(.headline)
            
            let stats = getWeeklyStats()
            
            WeeklyReviewStatCard(
                title: "Выполнено",
                value: "\(stats.completed)",
                subtitle: "из \(stats.total) целей",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            WeeklyReviewStatCard(
                title: "Процент успеха",
                value: "\(Int(stats.successRate))%",
                subtitle: stats.successRate >= 80 ? "Отлично!" : stats.successRate >= 60 ? "Хорошо" : "Можно лучше",
                icon: "chart.bar.fill",
                color: stats.successRate >= 80 ? .green : stats.successRate >= 60 ? .orange : .red
            )
            
            WeeklyReviewStatCard(
                title: "Средний стрик",
                value: String(format: "%.1f", stats.averageStreak),
                subtitle: "дней подряд",
                icon: "flame.fill",
                color: .orange
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var improvements: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Улучшения")
                .font(.headline)
            
            let improvements = getImprovements()
            
            ForEach(improvements, id: \.self) { improvement in
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    
                    Text(improvement)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
    
    private var whatToImprove: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Что можно улучшить")
                .font(.headline)
            
            let improvements = getImprovementsList()
            
            ForEach(improvements, id: \.self) { item in
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text(item)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private var reward: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Отличная работа на этой неделе!")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            let progress = GamificationService.shared.getUserProgress()
            Text("Вы заработали баллы и достигли уровня \(progress.currentLevel)!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private func getWeeklyStats() -> (completed: Int, total: Int, successRate: Double, averageStreak: Double) {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return (0, 0, 0, 0)
        }
        
        var completed = 0
        var total = 0
        var totalStreak = 0
        
        for habit in habits {
            let weekCompletions = habit.completions.filter { completion in
                completion.completedAt >= weekStart && completion.completedAt <= today
            }
            
            let expected = Int(habit.goalValue)
            total += expected
            completed += min(weekCompletions.count, expected)
            totalStreak += habit.currentStreak()
        }
        
        let successRate = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
        let averageStreak = habits.isEmpty ? 0.0 : Double(totalStreak) / Double(habits.count)
        
        return (completed, total, successRate, averageStreak)
    }
    
    private func getImprovements() -> [String] {
        var improvements: [String] = []
        let stats = getWeeklyStats()
        
        if stats.successRate > 80 {
            improvements.append("Вы достигли более 80% успеха на этой неделе!")
        }
        
        let activeHabits = habits.filter { $0.currentStreak() > 0 }
        if activeHabits.count == habits.count {
            improvements.append("Все ваши привычки имеют активные стрики!")
        }
        
        return improvements
    }
    
    private func getImprovementsList() -> [String] {
        var items: [String] = []
        let stats = getWeeklyStats()
        
        if stats.successRate < 60 {
            items.append("Попробуйте установить более реалистичные цели")
        }
        
        let lowStreakHabits = habits.filter { $0.currentStreak() < 3 }
        if !lowStreakHabits.isEmpty {
            items.append("\(lowStreakHabits.count) привычкам нужна большая последовательность")
        }
        
        return items
    }
}

struct WeeklyReviewStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    WeeklyReviewView(habits: [])
}

