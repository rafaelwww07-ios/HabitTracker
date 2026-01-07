//
//  CreateHabitViewModel.swift
//  HabitTracker
//
//  ViewModel for creating and editing habits
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CreateHabitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var selectedColor: Color = .blue
    @Published var selectedIcon: String = "star.fill"
    @Published var selectedCategory: HabitCategory? = nil
    @Published var goalType: GoalType = .daysPerWeek
    @Published var goalValue: Int16 = 7
    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var reminderDays: Set<Int> = [2, 3, 4, 5, 6] // Monday - Friday
    @Published var isReminderEnabled: Bool = false
    
    let existingHabit: Habit?
    
    init(existingHabit: Habit? = nil) {
        self.existingHabit = existingHabit
        
        if let habit = existingHabit {
            self.name = habit.name
            self.description = habit.description
            self.selectedColor = habit.color
            self.selectedIcon = habit.iconName
            self.selectedCategory = habit.category
            self.goalType = habit.goalType
            self.goalValue = habit.goalValue
            
            if let reminder = habit.reminders.first {
                self.reminderTime = reminder.time
                self.reminderDays = reminder.daysOfWeek
                self.isReminderEnabled = reminder.isEnabled
            }
        }
    }
    
    /// Create/update habit
    func saveHabit() -> Habit {
        let reminders: [HabitReminder] = isReminderEnabled ? [
            HabitReminder(
                habitId: existingHabit?.id ?? UUID(),
                time: reminderTime,
                daysOfWeek: reminderDays,
                isEnabled: true
            )
        ] : []
        
        if let existing = existingHabit {
            return Habit(
                id: existing.id,
                name: name,
                description: description,
                colorHex: selectedColor.toHex(),
                iconName: selectedIcon,
                category: selectedCategory,
                goalType: goalType,
                goalValue: goalValue,
                createdAt: existing.createdAt,
                isArchived: existing.isArchived,
                completions: existing.completions,
                reminders: reminders
            )
        } else {
            return Habit(
                name: name,
                description: description,
                colorHex: selectedColor.toHex(),
                iconName: selectedIcon,
                category: selectedCategory,
                goalType: goalType,
                goalValue: goalValue,
                reminders: reminders
            )
        }
    }
    
    /// Data validation
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && goalValue > 0
    }
    
    /// Available colors
    let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]
    
    /// Available icons
    let availableIcons: [String] = [
        "star.fill", "heart.fill", "flame.fill", "leaf.fill",
        "figure.run", "dumbbell.fill", "book.fill", "pencil",
        "moon.fill", "sun.max.fill", "drop.fill", "airplane",
        "gamecontroller.fill", "music.note", "camera.fill", "brain.head.profile"
    ]
}

