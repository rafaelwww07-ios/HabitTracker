//
//  Achievement.swift
//  HabitTracker
//
//  Achievement model
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
            return "First Habit"
        case .weekStreak:
            return "Week Streak"
        case .monthStreak:
            return "Month Streak"
        case .quarterStreak:
            return "Quarter Streak"
        case .yearStreak:
            return "Year Streak"
        case .perfectWeek:
            return "Perfect Week"
        case .perfectMonth:
            return "Perfect Month"
        case .hundredCompletions:
            return "Hundred Completions"
        }
    }
    
    var description: String {
        switch self {
        case .firstHabit:
            return "Create your first habit"
        case .weekStreak:
            return "Keep a streak for 7 days"
        case .monthStreak:
            return "Keep a streak for 30 days"
        case .quarterStreak:
            return "Keep a streak for 90 days"
        case .yearStreak:
            return "Keep a streak for 365 days"
        case .perfectWeek:
            return "Complete all goals for the week"
        case .perfectMonth:
            return "Complete all goals for the month"
        case .hundredCompletions:
            return "Complete a habit 100 times"
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
    let value: Int? // Additional value (e.g., number of days)
    
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



