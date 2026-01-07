//
//  HabitListViewModel.swift
//  HabitTracker
//
//  ViewModel for main screen with habit list
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateHabit = false
    @Published var selectedHabit: Habit?
    @Published var editingHabit: Habit?
    
    internal let repository: HabitRepositoryProtocol
    private let notificationManager: NotificationManagerProtocol
    
    init(
        repository: HabitRepositoryProtocol = HabitRepository(),
        notificationManager: NotificationManagerProtocol = NotificationManager.shared
    ) {
        self.repository = repository
        self.notificationManager = notificationManager
    }
    
    /// Load all habits
    func loadHabits() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedHabits = try await repository.fetchAll()
                habits = fetchedHabits
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    /// Toggle habit completion for today
    func toggleCompletion(for habit: Habit) {
        Task {
            do {
                try await repository.toggleCompletion(for: habit.id, date: Date())
                
                // Обновляем локальное состояние
                if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                    var updatedHabit = habit
                    let isCompleted = habit.isCompletedToday()
                    
                    if isCompleted {
                        // Удаляем выполнение
                        updatedHabit.completions.removeAll { completion in
                            let calendar = Calendar.current
                            let today = calendar.startOfDay(for: Date())
                            return calendar.isDate(completion.completedAt, inSameDayAs: today)
                        }
                    } else {
                        // Добавляем выполнение
                        let newCompletion = HabitCompletion(habitId: habit.id, completedAt: Date())
                        updatedHabit.completions.append(newCompletion)
                        
                        // Начисляем баллы
                        GamificationService.shared.updateProgressAfterCompletion(
                            habit: updatedHabit,
                            completion: newCompletion
                        )
                        
                        // Проверяем достижения
                        var progress = GamificationService.shared.getUserProgress()
                        GamificationService.shared.checkAndAwardAchievements(
                            habit: updatedHabit,
                            progress: &progress
                        )
                        GamificationService.shared.saveUserProgress(progress)
                    }
                    
                    habits[index] = updatedHabit
                    
                    // Проверяем достижения
                    checkAchievements(for: updatedHabit)
                }
                
                // Перезагружаем для синхронизации
                loadHabits()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Удалить привычку
    func deleteHabit(_ habit: Habit) {
        Task {
            do {
                try await repository.delete(habit)
                loadHabits()
                
                // Удаляем связанные уведомления
                await notificationManager.removeNotifications(for: habit.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Открыть экран создания привычки
    func showCreateHabit() {
        editingHabit = nil
        showingCreateHabit = true
    }
    
    /// Открыть экран редактирования привычки
    func editHabit(_ habit: Habit) {
        editingHabit = habit
        showingCreateHabit = true
    }
    
    /// Открыть детали привычки
    func showHabitDetails(_ habit: Habit) {
        selectedHabit = habit
    }
    
    /// Сохранить привычку (после создания/редактирования)
    func saveHabit(_ habit: Habit) {
        Task {
            do {
                try await repository.save(habit)
                loadHabits()
                
                // Обновляем уведомления
                await notificationManager.scheduleNotifications(for: habit)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Проверить достижения
    private func checkAchievements(for habit: Habit) {
        let streak = habit.currentStreak()
        
        // Проверка достижений реализована в AchievementService
        // Здесь можно добавить дополнительную логику уведомлений
        if streak >= 7 || streak >= 30 || streak >= 90 {
            // Достижения обрабатываются через AchievementService
        }
    }
}

