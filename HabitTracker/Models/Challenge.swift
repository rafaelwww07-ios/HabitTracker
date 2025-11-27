//
//  Challenge.swift
//  HabitTracker
//
//  Модель челленджа (вызова)
//

import Foundation
import SwiftUI

struct Challenge: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var duration: Int // Количество дней
    var habitIds: [UUID]
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var isCompleted: Bool
    var currentDay: Int
    var completions: [UUID] // IDs выполненных дней
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        duration: Int = 30,
        habitIds: [UUID] = [],
        startDate: Date = Date(),
        isActive: Bool = true,
        isCompleted: Bool = false,
        currentDay: Int = 1,
        completions: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.habitIds = habitIds
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) ?? startDate
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.currentDay = currentDay
        self.completions = completions
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return Double(completions.count) / Double(duration)
    }
    
    var daysRemaining: Int {
        max(0, duration - currentDay + 1)
    }
    
    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completions.contains { completionId in
            // Упрощенная проверка
            true
        }
    }
}

enum ChallengeTemplate: String, CaseIterable, Identifiable {
    case thirtyDays = "30-дневный вызов"
    case perfectWeek = "Идеальная неделя"
    case morningRoutine = "Утренний распорядок"
    case eveningRoutine = "Вечерний распорядок"
    case weekendWarrior = "Выходной воин"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .thirtyDays:
            return "30 дней подряд без пропусков"
        case .perfectWeek:
            return "7 дней идеального выполнения"
        case .morningRoutine:
            return "Утренние привычки 7 дней"
        case .eveningRoutine:
            return "Вечерние привычки 7 дней"
        case .weekendWarrior:
            return "Активность на выходных"
        }
    }
    
    var duration: Int {
        switch self {
        case .thirtyDays:
            return 30
        case .perfectWeek, .morningRoutine, .eveningRoutine:
            return 7
        case .weekendWarrior:
            return 14
        }
    }
}

extension Challenge: Codable {}

