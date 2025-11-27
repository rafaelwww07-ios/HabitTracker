//
//  BackupView.swift
//  HabitTracker
//
//  Экран резервного копирования
//

import SwiftUI
import os.log

struct BackupView: View {
    let habits: [Habit]
    @State private var backupData: Data?
    
    var body: some View {
        List {
            Section {
                Button(action: {
                    createBackup()
                }) {
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .foregroundColor(.blue)
                        Text("Создать резервную копию")
                    }
                }
                
                if backupData != nil {
                    Button(action: {
                        shareBackup()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                            Text("Поделиться резервной копией")
                        }
                    }
                }
            } header: {
                Text("Резервное копирование")
            } footer: {
                Text("Создайте резервную копию ваших данных, чтобы не потерять прогресс. Рекомендуется делать это регулярно.")
            }
        }
        .navigationTitle("Резервное копирование")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func createBackup() {
        do {
            backupData = try ExportService.shared.exportToJSON(habits: habits)
            // Сохраняем в UserDefaults для быстрого доступа
            if let data = backupData {
                UserDefaults.standard.set(data, forKey: "lastBackup")
                UserDefaults.standard.set(Date(), forKey: "lastBackupDate")
            }
        } catch {
            Logger.general.error("Ошибка создания резервной копии: \(error.localizedDescription)")
        }
    }
    
    private func shareBackup() {
        guard let data = backupData else { return }
        let filename = "HabitTracker_Backup_\(Date().timeIntervalSince1970).json"
        if let url = ExportService.shared.saveData(data: data, filename: filename) {
            ShareService.shared.share(items: [url], from: nil)
        }
    }
}

#Preview {
    NavigationView {
        BackupView(habits: [])
    }
}

