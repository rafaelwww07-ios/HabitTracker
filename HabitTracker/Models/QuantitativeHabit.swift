//
//  QuantitativeHabit.swift
//  HabitTracker
//
//  Привычки с количественными значениями
//

import Foundation

enum QuantityType: String, CaseIterable, Identifiable {
    case steps = "Шаги"
    case minutes = "Минуты"
    case hours = "Часы"
    case kilometers = "Километры"
    case liters = "Литры"
    case kilograms = "Килограммы"
    case times = "Раз"
    case custom = "Кастомное"
    
    var id: String { rawValue }
    
    var unit: String {
        switch self {
        case .steps: return "шагов"
        case .minutes: return "мин"
        case .hours: return "ч"
        case .kilometers: return "км"
        case .liters: return "л"
        case .kilograms: return "кг"
        case .times: return "раз"
        case .custom: return ""
        }
    }
}

struct QuantitativeCompletion {
    let id: UUID
    let habitId: UUID
    let date: Date
    let quantity: Double
    let unit: String
    let notes: String?
    
    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: Date = Date(),
        quantity: Double,
        unit: String,
        notes: String? = nil
    ) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.quantity = quantity
        self.unit = unit
        self.notes = notes
    }
}




