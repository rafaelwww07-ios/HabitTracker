//
//  ComparisonView.swift
//  HabitTracker
//
//  Сравнение периодов (этот месяц vs прошлый)
//

import SwiftUI
import Charts

struct ComparisonView: View {
    let habits: [Habit]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Общее сравнение
                    overallComparison
                    
                    // Сравнение по привычкам
                    habitsComparison
                }
                .padding()
            }
            .navigationTitle("Сравнение периодов")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overallComparison: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Общее сравнение")
                .font(.headline)
            
            let currentStats = getCurrentMonthStats()
            let previousStats = getPreviousMonthStats()
            
            ComparisonCard(
                title: "Всего выполнений",
                current: Double(Int(currentStats.totalCompletions)),
                previous: Double(Int(previousStats.totalCompletions)),
                unit: ""
            )
            
            ComparisonCard(
                title: "Средний стрик",
                current: currentStats.averageStreak,
                previous: previousStats.averageStreak,
                unit: " дней"
            )
            
            ComparisonCard(
                title: "Процент успеха",
                current: currentStats.successRate,
                previous: previousStats.successRate,
                unit: "%"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
    
    private var habitsComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("По привычкам")
                .font(.headline)
            
            ForEach(habits) { habit in
                let current = getHabitCompletionsForMonth(habit: habit, isCurrent: true)
                let previous = getHabitCompletionsForMonth(habit: habit, isCurrent: false)
                let trend = current > previous ? "↑" : current < previous ? "↓" : "→"
                let trendColor: Color = current > previous ? .green : current < previous ? .red : .gray
                
                HStack {
                    Image(systemName: habit.iconName)
                        .foregroundColor(habit.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(current) vs \(previous) выполнений")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(trend)
                        .font(.title2)
                        .foregroundColor(trendColor)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
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
    
    private func getCurrentMonthStats() -> MonthStats {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return MonthStats()
        }
        
        let completions = getAllCompletions(from: monthStart, to: now)
        let streaks = habits.map { $0.currentStreak() }
        
        return MonthStats(
            totalCompletions: completions.count,
            averageStreak: streaks.isEmpty ? 0 : Double(streaks.reduce(0, +)) / Double(streaks.count),
            successRate: calculateSuccessRate(from: monthStart, to: now)
        )
    }
    
    private func getPreviousMonthStats() -> MonthStats {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return MonthStats()
        }
        
        guard let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart) else {
            return MonthStats()
        }
        
        let previousMonthEnd = monthStart
        let completions = getAllCompletions(from: previousMonthStart, to: previousMonthEnd)
        
        return MonthStats(
            totalCompletions: completions.count,
            averageStreak: 0, // Упрощенная версия
            successRate: calculateSuccessRate(from: previousMonthStart, to: previousMonthEnd)
        )
    }
    
    private func getAllCompletions(from startDate: Date, to endDate: Date) -> [HabitCompletion] {
        habits.flatMap { habit in
            habit.completions.filter { completion in
                completion.completedAt >= startDate && completion.completedAt <= endDate
            }
        }
    }
    
    private func getHabitCompletionsForMonth(habit: Habit, isCurrent: Bool) -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }
        
        let startDate: Date
        let endDate: Date
        
        if isCurrent {
            startDate = monthStart
            endDate = now
        } else {
            guard let previousStart = calendar.date(byAdding: .month, value: -1, to: monthStart) else {
                return 0
            }
            startDate = previousStart
            endDate = monthStart
        }
        
        return habit.completions.filter { completion in
            completion.completedAt >= startDate && completion.completedAt <= endDate
        }.count
    }
    
    private func calculateSuccessRate(from startDate: Date, to endDate: Date) -> Double {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let totalCompletions = getAllCompletions(from: startDate, to: endDate).count
        let expectedCompletions = habits.reduce(0) { $0 + Int($1.goalValue) } * days / 7
        
        guard expectedCompletions > 0 else { return 0 }
        return Double(totalCompletions) / Double(expectedCompletions) * 100.0
    }
}

struct MonthStats {
    var totalCompletions: Int = 0
    var averageStreak: Double = 0
    var successRate: Double = 0
}

struct ComparisonCard: View {
    let title: String
    let current: Double
    let previous: Double
    let unit: String
    
    var difference: Double {
        current - previous
    }
    
    var percentageChange: Double {
        guard previous != 0 else { return 0 }
        return (difference / previous) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Этот месяц")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(current))\(unit)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Прошлый месяц")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(previous))\(unit)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            
            Divider()
            
            HStack {
                Text(difference >= 0 ? "Улучшение" : "Снижение")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(difference >= 0 ? "+" : "")\(String(format: "%.1f", difference))\(unit) (\(String(format: "%.1f", percentageChange))%)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(difference >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    ComparisonView(habits: [])
}

