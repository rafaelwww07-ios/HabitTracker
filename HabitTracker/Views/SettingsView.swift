//
//  SettingsView.swift
//  HabitTracker
//
//  Settings screen
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
                // Theme
                Section("Appearance") {
                    Picker("Theme", selection: $themeManager.currentTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                // Data
                Section("Data") {
                    NavigationLink(destination: ExportOptionsView(habit: nil, allHabits: habits)) {
                        Label("Export data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        showImportOptions = true
                    }) {
                        Label("Import data", systemImage: "square.and.arrow.down")
                    }
                    
                    NavigationLink(destination: BackupView(habits: habits)) {
                        Label("Backup", systemImage: "icloud.fill")
                    }
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    // TODO: Add support URL
                    // Link(destination: URL(string: "https://example.com")!) {
                    //     Label("Support", systemImage: "questionmark.circle")
                    // }
                    
                    // TODO: Add privacy policy URL
                    // Link(destination: URL(string: "https://example.com/privacy")!) {
                    //     Label("Privacy Policy", systemImage: "hand.raised.fill")
                    // }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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

