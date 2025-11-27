//
//  Achievement.swift
//  HabitTracker
//
//  Модель достижения
//

import Foundation
import SwiftUI

enum AchievementType: String, CaseIterable {
    case firstHabit = "first_habit"
    case weekStreak = "week_streak"
    case monthStreak = "month_streak"
    case quarterStreak = "quarter_streak"
    case perfectWeek = "perfect_week"
    case perfectMonth = "perfect_month"
    case hundredCompletions = "hundred_completions"
    case yearStreak = "year_streak"
    
    var title: String {
        switch self {
        case .firstHabit:
            return "Первая привычка"
        case .weekStreak:
            return "Неделя подряд"
        case .monthStreak:
            return "Месяц подряд"
        case .quarterStreak:
            return "Квартал подряд"
        case .yearStreak:
            return "Год подряд"
        case .perfectWeek:
            return "Идеальная неделя"
        case .perfectMonth:
            return "Идеальный месяц"
        case .hundredCompletions:
            return "Сотня выполнений"
        }
    }
    
    var description: String {
        switch self {
        case .firstHabit:
            return "Создайте свою первую привычку"
        case .weekStreak:
            return "Держите стрик 7 дней подряд"
        case .monthStreak:
            return "Держите стрик 30 дней подряд"
        case .quarterStreak:
            return "Держите стрик 90 дней подряд"
        case .yearStreak:
            return "Держите стрик 365 дней подряд"
        case .perfectWeek:
            return "Выполните все цели на неделе"
        case .perfectMonth:
            return "Выполните все цели в месяце"
        case .hundredCompletions:
            return "Выполните привычку 100 раз"
        }
    }
    
    var icon: String {
        switch self {
        case .firstHabit:
            return "star.fill"
        case .weekStreak:
            return "flame.fill"
        case .monthStreak:
            return "flame.fill"
        case .quarterStreak:
            return "flame.fill"
        case .yearStreak:
            return "flame.fill"
        case .perfectWeek:
            return "checkmark.circle.fill"
        case .perfectMonth:
            return "checkmark.circle.fill"
        case .hundredCompletions:
            return "100.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstHabit:
            return .yellow
        case .weekStreak:
            return .orange
        case .monthStreak:
            return .red
        case .quarterStreak:
            return .purple
        case .yearStreak:
            return .blue
        case .perfectWeek:
            return .green
        case .perfectMonth:
            return .green
        case .hundredCompletions:
            return .indigo
        }
    }
}

struct Achievement: Identifiable, Hashable {
    let id: UUID
    let type: AchievementType
    let habitId: UUID?
    let unlockedAt: Date
    let value: Int? // Дополнительное значение (например, количество дней)
    
    init(
        id: UUID = UUID(),
        type: AchievementType,
        habitId: UUID? = nil,
        unlockedAt: Date = Date(),
        value: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.habitId = habitId
        self.unlockedAt = unlockedAt
        self.value = value
    }
}

