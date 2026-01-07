//
//  AchievementService.swift
//  HabitTracker
//
//  Сервис для проверки и отслеживания достижений
//

import Foundation

class AchievementService {
    static let shared = AchievementService()
    
    private init() {}
    
    /// Проверить достижения для привычки
    func checkAchievements(for habit: Habit, allHabits: [Habit]) -> [Achievement] {
        var achievements: [Achievement] = []
        
        // Проверка стриков
        let streak = habit.currentStreak()
        
        if streak >= 7 && !hasAchievement(.weekStreak, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .weekStreak, habitId: habit.id, value: 7))
        }
        
        if streak >= 30 && !hasAchievement(.monthStreak, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .monthStreak, habitId: habit.id, value: 30))
        }
        
        if streak >= 90 && !hasAchievement(.quarterStreak, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .quarterStreak, habitId: habit.id, value: 90))
        }
        
        if streak >= 365 && !hasAchievement(.yearStreak, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .yearStreak, habitId: habit.id, value: 365))
        }
        
        // Проверка количества выполнений
        if habit.completions.count >= 100 && !hasAchievement(.hundredCompletions, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .hundredCompletions, habitId: habit.id, value: 100))
        }
        
        // Проверка идеальной недели
        if hasPerfectWeek(habit: habit) && !hasAchievement(.perfectWeek, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .perfectWeek, habitId: habit.id))
        }
        
        // Проверка идеального месяца
        if hasPerfectMonth(habit: habit) && !hasAchievement(.perfectMonth, habitId: habit.id, in: allHabits) {
            achievements.append(Achievement(type: .perfectMonth, habitId: habit.id))
        }
        
        return achievements
    }
    
    /// Проверить общие достижения (не привязанные к конкретной привычке)
    func checkGlobalAchievements(allHabits: [Habit], existingAchievements: [Achievement]) -> [Achievement] {
        var achievements: [Achievement] = []
        
        // Первая привычка
        if allHabits.count >= 1 && !existingAchievements.contains(where: { $0.type == .firstHabit }) {
            achievements.append(Achievement(type: .firstHabit))
        }
        
        return achievements
    }
    
    private func hasAchievement(_ type: AchievementType, habitId: UUID?, in habits: [Habit]) -> Bool {
        // В реальном приложении это должно проверяться в базе данных
        // Здесь упрощенная версия
        return false
    }
    
    private func hasPerfectWeek(habit: Habit) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return false
        }
        
        let weekCompletions = habit.completions.filter { completion in
            completion.completedAt >= weekStart && completion.completedAt <= today
        }
        
        return weekCompletions.count >= Int(habit.goalValue)
    }
    
    private func hasPerfectMonth(habit: Habit) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return false
        }
        
        let monthCompletions = habit.completions.filter { completion in
            completion.completedAt >= monthStart && completion.completedAt <= today
        }
        
        // Для месячных целей - проверяем выполнение всех дней или всех целей
        if habit.goalType == .daysPerWeek {
            let weeksInMonth = 4 // Приблизительно
            let expectedCompletions = Int(habit.goalValue) * weeksInMonth
            return monthCompletions.count >= expectedCompletions
        } else {
            let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
            return monthCompletions.count >= daysInMonth
        }
    }
}




