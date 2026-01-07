//
//  HabitCategory.swift
//  HabitTracker
//
//  Habit categories
//

import Foundation
import SwiftUI

enum HabitCategory: String, CaseIterable, Identifiable {
    case health = "Health"
    case fitness = "Fitness"
    case learning = "Learning"
    case work = "Work"
    case personal = "Personal"
    case social = "Social"
    case creativity = "Creativity"
    case finance = "Finance"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .health:
            return "heart.fill"
        case .fitness:
            return "figure.run"
        case .learning:
            return "book.fill"
        case .work:
            return "briefcase.fill"
        case .personal:
            return "person.fill"
        case .social:
            return "person.2.fill"
        case .creativity:
            return "paintbrush.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health:
            return .red
        case .fitness:
            return .orange
        case .learning:
            return .blue
        case .work:
            return .purple
        case .personal:
            return .pink
        case .social:
            return .green
        case .creativity:
            return .yellow
        case .finance:
            return .mint
        case .other:
            return .gray
        }
    }
}



