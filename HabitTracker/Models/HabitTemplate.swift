//
//  HabitTemplate.swift
//  HabitTracker
//
//  Predefined habit templates
//

import Foundation
import SwiftUI

struct HabitTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let colorHex: String
    let category: HabitCategory
    let goalType: GoalType
    let goalValue: Int16
    
    static let templates: [HabitTemplate] = [
        HabitTemplate(
            name: "Morning Exercise",
            description: "15-30 minutes of physical exercise",
            iconName: "figure.run",
            colorHex: "#FF6B6B",
            category: .fitness,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Reading",
            description: "Read books for self-improvement",
            iconName: "book.fill",
            colorHex: "#4ECDC4",
            category: .learning,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Meditation",
            description: "Calming meditation",
            iconName: "leaf.fill",
            colorHex: "#95E1D3",
            category: .personal,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Drink Water",
            description: "Drink 8 glasses of water",
            iconName: "drop.fill",
            colorHex: "#3498DB",
            category: .health,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Daily Planning",
            description: "Create a plan for the day",
            iconName: "list.bullet",
            colorHex: "#9B59B6",
            category: .work,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Language Learning",
            description: "Practice a foreign language",
            iconName: "globe",
            colorHex: "#E74C3C",
            category: .learning,
            goalType: .daysPerWeek,
            goalValue: 6
        ),
        HabitTemplate(
            name: "Sleep 8 Hours",
            description: "Healthy sleep",
            iconName: "moon.fill",
            colorHex: "#34495E",
            category: .health,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Walking",
            description: "Walk in the fresh air",
            iconName: "figure.walk",
            colorHex: "#2ECC71",
            category: .health,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Journaling",
            description: "Write down thoughts and events",
            iconName: "book.closed.fill",
            colorHex: "#F39C12",
            category: .personal,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "No Social Media",
            description: "Don't use social media until evening",
            iconName: "hand.raised.fill",
            colorHex: "#E67E22",
            category: .personal,
            goalType: .daysPerWeek,
            goalValue: 5
        )
    ]
    
    func toHabit() -> Habit {
        Habit(
            name: name,
            description: description,
            colorHex: colorHex,
            iconName: iconName,
            category: category,
            goalType: goalType,
            goalValue: goalValue
        )
    }
}



