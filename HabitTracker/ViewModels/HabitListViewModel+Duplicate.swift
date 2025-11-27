//
//  HabitListViewModel+Duplicate.swift
//  HabitTracker
//
//  Расширение для дублирования привычек
//

import Foundation

extension HabitListViewModel {
    /// Дублировать привычку
    func duplicateHabit(_ habit: Habit) {
        let duplicatedHabit = Habit(
            name: "\(habit.name) (копия)",
            description: habit.description,
            colorHex: habit.colorHex,
            iconName: habit.iconName,
            category: habit.category,
            goalType: habit.goalType,
            goalValue: habit.goalValue
        )
        
        saveHabit(duplicatedHabit)
    }
    
    /// Архивировать привычку
    func archiveHabit(_ habit: Habit) {
        Task {
            do {
                var archivedHabit = habit
                archivedHabit.isArchived = true
                try await repository.save(archivedHabit)
                loadHabits()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Разархивировать привычку
    func unarchiveHabit(_ habit: Habit) {
        Task {
            do {
                var unarchivedHabit = habit
                unarchivedHabit.isArchived = false
                try await repository.save(unarchivedHabit)
                loadHabits()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

