//
//  ExportService.swift
//  HabitTracker
//
//  Сервис для экспорта данных
//

import Foundation
import os.log
import SwiftUI

enum ExportFormat {
    case csv
    case json
}

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    /// Экспортировать привычки в CSV
    func exportToCSV(habits: [Habit]) -> String {
        var csv = "Название,Описание,Категория,Создано,Всего выполнений,Текущий стрик,Процент успеха\n"
        
        for habit in habits {
            let category = habit.category?.rawValue ?? "Без категории"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let createdDate = dateFormatter.string(from: habit.createdAt)
            
            csv += "\"\(habit.name)\",\"\(habit.description)\",\"\(category)\",\"\(createdDate)\",\"\(habit.completions.count)\",\"\(habit.currentStreak())\",\"\(Int(habit.overallCompletionPercentage()))%\"\n"
        }
        
        return csv
    }
    
    /// Экспортировать привычки в JSON
    func exportToJSON(habits: [Habit]) throws -> Data {
        let dateFormatter = ISO8601DateFormatter()
        
        let exportData = habits.map { habit -> [String: Any] in
            var habitDict: [String: Any] = [
                "id": habit.id.uuidString,
                "name": habit.name,
                "description": habit.description,
                "colorHex": habit.colorHex,
                "iconName": habit.iconName,
                "goalType": habit.goalType.rawValue,
                "goalValue": habit.goalValue,
                "createdAt": dateFormatter.string(from: habit.createdAt),
                "totalCompletions": habit.completions.count,
                "currentStreak": habit.currentStreak(),
                "successRate": habit.overallCompletionPercentage()
            ]
            
            // Добавляем категорию, если она есть
            if let category = habit.category?.rawValue {
                habitDict["category"] = category
            } else {
                habitDict["category"] = NSNull()
            }
            
            // Маппинг выполнений
            habitDict["completions"] = habit.completions.map { completion -> [String: Any] in
                var completionDict: [String: Any] = [
                    "id": completion.id.uuidString,
                    "completedAt": dateFormatter.string(from: completion.completedAt)
                ]
                
                // Добавляем примечания, если они есть
                if let notes = completion.notes {
                    completionDict["notes"] = notes
                } else {
                    completionDict["notes"] = NSNull()
                }
                
                return completionDict
            }
            
            return habitDict
        }
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    /// Сохранить файл
    func saveFile(content: String, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent(filename)
        
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath
        } catch {
            Logger.export.error("Ошибка сохранения файла: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Сохранить данные
    func saveData(data: Data, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent(filename)
        
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            Logger.export.error("Ошибка сохранения данных: \(error.localizedDescription)")
            return nil
        }
    }
}

