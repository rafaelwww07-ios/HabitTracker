//
//  HabitTemplate.swift
//  HabitTracker
//
//  Шаблоны предустановленных привычек
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
            name: "Утренняя зарядка",
            description: "15-30 минут физических упражнений",
            iconName: "figure.run",
            colorHex: "#FF6B6B",
            category: .fitness,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Чтение",
            description: "Читать книги для саморазвития",
            iconName: "book.fill",
            colorHex: "#4ECDC4",
            category: .learning,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Медитация",
            description: "Успокаивающая медитация",
            iconName: "leaf.fill",
            colorHex: "#95E1D3",
            category: .personal,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Пить воду",
            description: "Выпивать 8 стаканов воды",
            iconName: "drop.fill",
            colorHex: "#3498DB",
            category: .health,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Планирование дня",
            description: "Составлять план на день",
            iconName: "list.bullet",
            colorHex: "#9B59B6",
            category: .work,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Изучение языка",
            description: "Практика иностранного языка",
            iconName: "globe",
            colorHex: "#E74C3C",
            category: .learning,
            goalType: .daysPerWeek,
            goalValue: 6
        ),
        HabitTemplate(
            name: "Спать 8 часов",
            description: "Здоровый сон",
            iconName: "moon.fill",
            colorHex: "#34495E",
            category: .health,
            goalType: .daysPerWeek,
            goalValue: 7
        ),
        HabitTemplate(
            name: "Прогулка",
            description: "Прогулка на свежем воздухе",
            iconName: "figure.walk",
            colorHex: "#2ECC71",
            category: .health,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Вести дневник",
            description: "Записывать мысли и события",
            iconName: "book.closed.fill",
            colorHex: "#F39C12",
            category: .personal,
            goalType: .daysPerWeek,
            goalValue: 5
        ),
        HabitTemplate(
            name: "Отказ от социальных сетей",
            description: "Не использовать соцсети до вечера",
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

