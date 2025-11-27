//
//  HabitDetailViewModel.swift
//  HabitTracker
//
//  ViewModel для экрана деталей привычки
//

import Foundation
import SwiftUI
import Combine
import os.log

@MainActor
class HabitDetailViewModel: ObservableObject {
    @Published var habit: Habit
    @Published var monthlyCompletions: [Date] = []
    @Published var weeklyStats: [Double] = []
    @Published var isLoading = false
    
    private let repository: HabitRepositoryProtocol
    
    init(habit: Habit, repository: HabitRepositoryProtocol = HabitRepository()) {
        self.habit = habit
        self.repository = repository
    }
    
    /// Загрузить данные для отображения
    func loadData() {
        isLoading = true
        
        Task {
            await loadMonthlyCompletions()
            await loadWeeklyStats()
            await refreshHabit()
            isLoading = false
        }
    }
    
    /// Переключить выполнение на сегодня
    func toggleCompletion() async throws {
        try await repository.toggleCompletion(for: habit.id, date: Date())
        await refreshHabit()
        await loadMonthlyCompletions()
    }
    
    /// Загрузить выполнения за текущий месяц
    private func loadMonthlyCompletions() async {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return
        }
        
        do {
            let completions = try await repository.getCompletions(for: habit.id, from: monthStart, to: monthEnd)
            monthlyCompletions = completions.map { $0.completedAt }
        } catch {
            Logger.general.error("Ошибка загрузки выполнений: \(error.localizedDescription)")
        }
    }
    
    /// Загрузить статистику по неделям (последние 12 недель)
    private func loadWeeklyStats() async {
        let calendar = Calendar.current
        var stats: [Double] = []
        
        for weekOffset in (0..<12).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()),
                  let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                continue
            }
            
            do {
                let completions = try await repository.getCompletions(for: habit.id, from: weekStart, to: weekEnd)
                let percentage = habit.goalType == .daysPerWeek
                    ? Double(completions.count) / Double(habit.goalValue) * 100.0
                    : (completions.count >= Int(habit.goalValue) ? 100.0 : 0.0)
                
                stats.append(min(percentage, 100.0))
            } catch {
                stats.append(0.0)
            }
        }
        
        weeklyStats = stats
    }
    
    /// Обновить данные привычки
    private func refreshHabit() async {
        do {
            if let updatedHabit = try await repository.fetch(by: habit.id) {
                habit = updatedHabit
            }
        } catch {
            Logger.general.error("Ошибка обновления привычки: \(error.localizedDescription)")
        }
    }
    
    /// Текущий стрик
    var currentStreak: Int {
        habit.currentStreak()
    }
    
    /// Процент успеха
    var successRate: Double {
        habit.overallCompletionPercentage()
    }
    
    /// Лучший стрик
    var bestStreak: Int {
        calculateBestStreak()
    }
    
    /// Вычисления лучшего стрика
    private func calculateBestStreak() -> Int {
        let calendar = Calendar.current
        let sortedCompletions = habit.completions.sorted { $0.completedAt < $1.completedAt }
        
        guard !sortedCompletions.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        var previousDate = calendar.startOfDay(for: sortedCompletions[0].completedAt)
        
        for i in 1..<sortedCompletions.count {
            let currentDate = calendar.startOfDay(for: sortedCompletions[i].completedAt)
            
            if let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
            
            previousDate = currentDate
        }
        
        return maxStreak
    }
    
    /// Данные для графика (последние 30 дней)
    var chartData: [(date: Date, completed: Bool)] {
        let calendar = Calendar.current
        var data: [(date: Date, completed: Bool)] = []
        
        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }
            
            let dayStart = calendar.startOfDay(for: date)
            let isCompleted = habit.completions.contains { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: dayStart)
            }
            
            data.append((date: dayStart, completed: isCompleted))
        }
        
        return data
    }
}

