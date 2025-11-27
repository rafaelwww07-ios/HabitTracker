//
//  ThemeManager.swift
//  HabitTracker
//
//  Менеджер тем оформления
//

import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Темная"
    case blue = "Голубая"
    case purple = "Фиолетовая"
    case green = "Зеленая"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light, .blue, .purple, .green:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .system, .light, .dark:
            return .blue
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .green:
            return .green
        }
    }
    
    var backgroundColor: LinearGradient {
        switch self {
        case .system, .light:
            return LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                colors: [Color.black.opacity(0.8), Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blue:
            return LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .purple:
            return LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [Color.green.opacity(0.2), Color.mint.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }
    
    static let shared = ThemeManager()
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
}

