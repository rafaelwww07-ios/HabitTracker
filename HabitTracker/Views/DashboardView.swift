//
//  DashboardView.swift
//  HabitTracker
//
//  Дашборд с ключевыми метриками
//

import SwiftUI

struct DashboardView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Быстрые метрики
                    quickMetrics
                    
                    // Привычки сегодня
                    todayHabits
                    
                    // Мотивационная карточка
                    motivationCard
                }
                .padding()
            }
            .navigationTitle("Дашборд")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var quickMetrics: some View {
        HStack(spacing: 16) {
            MetricCard(
                title: "Выполнено",
                value: "\(completedToday)",
                subtitle: "из \(habits.count)",
                color: .green
            )
            
            MetricCard(
                title: "Общий стрик",
                value: "\(totalStreak)",
                subtitle: "дней",
                color: .orange
            )
            
            MetricCard(
                title: "Успех",
                value: "\(Int(successRate))%",
                subtitle: "на этой неделе",
                color: .blue
            )
        }
    }
    
    private var todayHabits: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Привычки на сегодня")
                .font(.headline)
            
            let incompleteHabits = habits.filter { !$0.isCompletedToday() }
            
            if incompleteHabits.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Все привычки выполнены сегодня! 🎉")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                ForEach(incompleteHabits.prefix(5)) { habit in
                    HStack {
                        Image(systemName: habit.iconName)
                            .foregroundColor(habit.color)
                        
                        Text(habit.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("Стрик: \(habit.currentStreak())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
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
    
    private var motivationCard: some View {
        let quote = MotivationService.shared.quoteOfTheDay()
        let totalStreak = habits.reduce(0) { $0 + $1.currentStreak() }
        let message = MotivationService.shared.messageForStreak(totalStreak)
        
        return VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundColor(.purple)
            
            Text(quote.text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            if !message.isEmpty {
                Divider()
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    // MARK: - Computed Properties
    
    private var completedToday: Int {
        habits.filter { $0.isCompletedToday() }.count
    }
    
    private var totalStreak: Int {
        habits.reduce(0) { $0 + $1.currentStreak() }
    }
    
    private var successRate: Double {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return 0
        }
        
        var completed = 0
        var total = 0
        
        for habit in habits {
            let weekCompletions = habit.completions.filter { completion in
                completion.completedAt >= weekStart && completion.completedAt <= today
            }
            
            let expected = Int(habit.goalValue)
            total += expected
            completed += min(weekCompletions.count, expected)
        }
        
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total) * 100.0
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    DashboardView(habits: [])
}

