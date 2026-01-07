//
//  Habit.swift
//  HabitTracker
//
//  Domain model for habits
//

import Foundation
import SwiftUI
import UIKit

/// Habit goal type
enum GoalType: Int16, CaseIterable {
    case daysPerWeek = 0
    case consecutiveDays = 1
    
    var description: String {
        switch self {
        case .daysPerWeek:
            return "Days per week"
        case .consecutiveDays:
            return "Consecutive days"
        }
    }
}

/// Habit model
struct Habit: Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var colorHex: String
    var iconName: String
    var category: HabitCategory?
    var goalType: GoalType
    var goalValue: Int16
    var createdAt: Date
    var isArchived: Bool
    var completions: [HabitCompletion]
    var reminders: [HabitReminder]
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        colorHex: String = "#007AFF",
        iconName: String = "star.fill",
        category: HabitCategory? = nil,
        goalType: GoalType = .daysPerWeek,
        goalValue: Int16 = 7,
        createdAt: Date = Date(),
        isArchived: Bool = false,
        completions: [HabitCompletion] = [],
        reminders: [HabitReminder] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.colorHex = colorHex
        self.iconName = iconName
        self.category = category
        self.goalType = goalType
        self.goalValue = goalValue
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.completions = completions
        self.reminders = reminders
    }
    
    /// Check if completed today
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completions.contains { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: today)
        }
    }
    
    /// Current streak (consecutive days)
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let sortedCompletions = completions.sorted { $0.completedAt > $1.completedAt }
        
        guard !sortedCompletions.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // If not completed today, start from yesterday
        if !isCompletedToday() {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        for completion in sortedCompletions {
            let completionDate = calendar.startOfDay(for: completion.completedAt)
            
            if calendar.isDate(completionDate, inSameDayAs: currentDate) {
                streak += 1
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = previousDate
                } else {
                    break
                }
            } else if completionDate < currentDate {
                // Days missed - streak broken
                break
            }
        }
        
        return streak
    }
    
    /// Completion percentage for current week
    func weeklyCompletionPercentage() -> Double {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return 0
        }
        
        let weekCompletions = completions.filter { completion in
            completion.completedAt >= weekStart && completion.completedAt <= today
        }
        
        let daysCount = min(7, calendar.dateComponents([.day], from: weekStart, to: today).day ?? 0)
        guard daysCount > 0 else { return 0 }
        
        return Double(weekCompletions.count) / Double(goalValue) * 100.0
    }
    
    /// Completion percentage for all time
    func overallCompletionPercentage() -> Double {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
        guard daysSinceCreation > 0 else { return 0 }
        
        return Double(completions.count) / Double(daysSinceCreation) * 100.0
    }
}

/// Habit completion model
struct HabitCompletion: Identifiable, Hashable {
    let id: UUID
    let habitId: UUID
    let completedAt: Date
    var notes: String?
    
    init(id: UUID = UUID(), habitId: UUID, completedAt: Date = Date(), notes: String? = nil) {
        self.id = id
        self.habitId = habitId
        self.completedAt = completedAt
        self.notes = notes
    }
}

/// Reminder model
struct HabitReminder: Identifiable, Hashable {
    let id: UUID
    let habitId: UUID
    var time: Date
    var daysOfWeek: Set<Int> // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        habitId: UUID,
        time: Date,
        daysOfWeek: Set<Int> = [],
        isEnabled: Bool = true
    ) {
        self.id = id
        self.habitId = habitId
        self.time = time
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
    }
}

/// Color extension for HEX support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let uic = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uic.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        
        return String(format: "#%06x", rgb)
    }
}

