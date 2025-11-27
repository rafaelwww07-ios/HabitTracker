//
//  SettingsView.swift
//  HabitTracker
//
//  Экран настроек
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    let habits: [Habit]
    @State private var showImportOptions = false
    
    var body: some View {
        NavigationView {
            List {
                // Тема оформления
                Section("Внешний вид") {
                    Picker("Тема", selection: $themeManager.currentTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                // Данные
                Section("Данные") {
                    NavigationLink(destination: ExportOptionsView(habit: nil, allHabits: habits)) {
                        Label("Экспорт данных", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        showImportOptions = true
                    }) {
                        Label("Импорт данных", systemImage: "square.and.arrow.down")
                    }
                    
                    NavigationLink(destination: BackupView(habits: habits)) {
                        Label("Резервное копирование", systemImage: "icloud.fill")
                    }
                }
                
                // О приложении
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    // TODO: Add support URL
                    // Link(destination: URL(string: "https://example.com")!) {
                    //     Label("Поддержка", systemImage: "questionmark.circle")
                    // }
                    
                    // TODO: Add privacy policy URL
                    // Link(destination: URL(string: "https://example.com/privacy")!) {
                    //     Label("Политика конфиденциальности", systemImage: "hand.raised.fill")
                    // }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(habits: [])
}

