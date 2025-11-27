//
//  Habit+CoreData.swift
//  HabitTracker
//
//  Расширения Core Data Entities для конвертации в доменные модели
//

import Foundation
import CoreData

extension HabitEntity {
    func toDomain() -> Habit {
        let completions = (self.completions as? Set<HabitCompletionEntity>)?
            .map { $0.toDomain(habitId: self.id!) } ?? []
        
        let reminders = (self.reminders as? Set<HabitReminderEntity>)?
            .map { $0.toDomain(habitId: self.id!) } ?? []
        
        let category: HabitCategory? = {
            if let categoryString = self.category {
                return HabitCategory(rawValue: categoryString)
            }
            return nil
        }()
        
        return Habit(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            description: self.desc ?? "",
            colorHex: self.colorHex ?? "#007AFF",
            iconName: self.iconName ?? "star.fill",
            category: category,
            goalType: GoalType(rawValue: self.goalType) ?? .daysPerWeek,
            goalValue: self.goalValue,
            createdAt: self.createdAt ?? Date(),
            isArchived: self.isArchived,
            completions: completions,
            reminders: reminders
        )
    }
    
    func update(from habit: Habit, context: NSManagedObjectContext) {
        self.id = habit.id
        self.name = habit.name
        self.desc = habit.description
        self.colorHex = habit.colorHex
        self.iconName = habit.iconName
        self.category = habit.category?.rawValue
        self.goalType = habit.goalType.rawValue
        self.goalValue = habit.goalValue
        self.createdAt = habit.createdAt
        self.isArchived = habit.isArchived
        
        // Обновляем completions
        if let existingCompletions = self.completions as? Set<HabitCompletionEntity> {
            for completion in existingCompletions {
                context.delete(completion)
            }
        }
        
        for completion in habit.completions {
            let entity = HabitCompletionEntity(context: context)
            entity.id = completion.id
            entity.completedAt = completion.completedAt
            entity.notes = completion.notes
            entity.habit = self
        }
        
        // Обновляем reminders
        if let existingReminders = self.reminders as? Set<HabitReminderEntity> {
            for reminder in existingReminders {
                context.delete(reminder)
            }
        }
        
        for reminder in habit.reminders {
            let entity = HabitReminderEntity(context: context)
            entity.id = reminder.id
            entity.time = reminder.time
            entity.daysOfWeek = reminder.daysOfWeek.map(String.init).joined(separator: ",")
            entity.isEnabled = reminder.isEnabled
            entity.habit = self
        }
    }
}

extension HabitCompletionEntity {
    func toDomain(habitId: UUID) -> HabitCompletion {
        HabitCompletion(
            id: self.id ?? UUID(),
            habitId: habitId,
            completedAt: self.completedAt ?? Date(),
            notes: self.notes
        )
    }
}

extension HabitReminderEntity {
    func toDomain(habitId: UUID) -> HabitReminder {
        let daysSet = Set((self.daysOfWeek ?? "").split(separator: ",").compactMap { Int($0) })
        
        return HabitReminder(
            id: self.id ?? UUID(),
            habitId: habitId,
            time: self.time ?? Date(),
            daysOfWeek: daysSet,
            isEnabled: self.isEnabled
        )
    }
}

