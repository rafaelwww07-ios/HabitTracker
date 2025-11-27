//
//  HabitGroup.swift
//  HabitTracker
//
//  Группы привычек
//

import Foundation
import SwiftUI

struct HabitGroup: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var colorHex: String
    var iconName: String
    var habitIds: [UUID]
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill",
        habitIds: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.colorHex = colorHex
        self.iconName = iconName
        self.habitIds = habitIds
        self.createdAt = createdAt
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension HabitGroup: Codable {}

