//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Главный файл приложения
//

import SwiftUI
import CoreData

@main
struct HabitTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }
}
