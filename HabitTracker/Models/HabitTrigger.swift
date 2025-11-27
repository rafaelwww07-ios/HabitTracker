//
//  HabitTrigger.swift
//  HabitTracker
//
//  Привычки-триггеры (если X, то Y)
//

import Foundation

struct HabitTrigger: Identifiable {
    let id: UUID
    var triggerHabitId: UUID // Привычка-триггер
    var targetHabitId: UUID // Привычка-цель
    var condition: TriggerCondition
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        triggerHabitId: UUID,
        targetHabitId: UUID,
        condition: TriggerCondition,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.triggerHabitId = triggerHabitId
        self.targetHabitId = targetHabitId
        self.condition = condition
        self.isEnabled = isEnabled
    }
}

enum TriggerCondition: String, CaseIterable, Codable {
    case completed = "Выполнена"
    case notCompleted = "Не выполнена"
    case streakReached = "Стрик достигнут"
    case streakBroken = "Стрик прерван"
    
    var description: String {
        switch self {
        case .completed:
            return "Когда привычка выполнена"
        case .notCompleted:
            return "Когда привычка не выполнена"
        case .streakReached:
            return "Когда достигнут определенный стрик"
        case .streakBroken:
            return "Когда стрик прерван"
        }
    }
}

extension HabitTrigger: Codable {}

