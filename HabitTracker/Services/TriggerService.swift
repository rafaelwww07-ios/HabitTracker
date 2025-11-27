//
//  TriggerService.swift
//  HabitTracker
//
//  Сервис для управления триггерами привычек
//

import Foundation

class TriggerService {
    static let shared = TriggerService()
    
    private let userDefaults = UserDefaults.standard
    private let triggersKey = "habitTriggers"
    
    private init() {}
    
    /// Получить все триггеры
    func getAllTriggers() -> [HabitTrigger] {
        guard let data = userDefaults.data(forKey: triggersKey),
              let triggers = try? JSONDecoder().decode([HabitTrigger].self, from: data) else {
            return []
        }
        return triggers
    }
    
    /// Сохранить триггеры
    func saveTriggers(_ triggers: [HabitTrigger]) {
        if let data = try? JSONEncoder().encode(triggers) {
            userDefaults.set(data, forKey: triggersKey)
        }
    }
    
    /// Создать триггер
    func createTrigger(_ trigger: HabitTrigger) {
        var triggers = getAllTriggers()
        triggers.append(trigger)
        saveTriggers(triggers)
    }
    
    /// Удалить триггер
    func deleteTrigger(_ triggerId: UUID) {
        var triggers = getAllTriggers()
        triggers.removeAll { $0.id == triggerId }
        saveTriggers(triggers)
    }
    
    /// Проверить и выполнить триггеры
    func checkTriggers(habitId: UUID, habits: [Habit], onTrigger: (UUID) -> Void) {
        let triggers = getAllTriggers().filter { $0.isEnabled && $0.triggerHabitId == habitId }
        
        guard let triggerHabit = habits.first(where: { $0.id == habitId }) else {
            return
        }
        
        for trigger in triggers {
            let shouldTrigger: Bool
            
            switch trigger.condition {
            case .completed:
                shouldTrigger = triggerHabit.isCompletedToday()
            case .notCompleted:
                shouldTrigger = !triggerHabit.isCompletedToday()
            case .streakReached:
                shouldTrigger = triggerHabit.currentStreak() >= 7
            case .streakBroken:
                shouldTrigger = triggerHabit.currentStreak() == 0 && triggerHabit.completions.count > 0
            }
            
            if shouldTrigger {
                onTrigger(trigger.targetHabitId)
            }
        }
    }
}
