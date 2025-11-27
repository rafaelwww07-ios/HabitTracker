//
//  PDFExportService.swift
//  HabitTracker
//
//  Сервис для экспорта в PDF
//

import Foundation
import PDFKit
import UIKit
import os.log
import SwiftUI
import UIKit

class PDFExportService {
    static let shared = PDFExportService()
    
    private init() {}
    
    /// Создать PDF отчет о привычках
    func createPDFReport(habits: [Habit], title: String = "Отчет о привычках") -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "HabitTracker",
            kCGPDFContextAuthor: "HabitTracker App",
            kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = 72
            
            // Заголовок
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let titleText = NSAttributedString(string: title, attributes: titleAttributes)
            titleText.draw(at: CGPoint(x: 72, y: yPosition))
            yPosition += 40
            
            // Дата создания
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let dateString = "Дата создания: \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let dateText = NSAttributedString(string: dateString, attributes: dateAttributes)
            dateText.draw(at: CGPoint(x: 72, y: yPosition))
            yPosition += 30
            
            // Общая статистика
            let totalCompletions = habits.reduce(0) { $0 + $1.completions.count }
            let totalStreak = habits.reduce(0) { $0 + $1.currentStreak() }
            
            let statsText = """
            Всего привычек: \(habits.count)
            Всего выполнений: \(totalCompletions)
            Общий стрик: \(totalStreak) дней
            """
            
            let statsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
            
            let stats = NSAttributedString(string: statsText, attributes: statsAttributes)
            stats.draw(at: CGPoint(x: 72, y: yPosition))
            yPosition += 80
            
            // Детали по привычкам
            for habit in habits {
                if yPosition > pageHeight - 200 {
                    context.beginPage()
                    yPosition = 72
                }
                
                let habitText = """
                \(habit.name)
                Стрик: \(habit.currentStreak()) дней | Выполнений: \(habit.completions.count)
                Процент успеха: \(Int(habit.overallCompletionPercentage()))%
                
                """
                
                let habitAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ]
                
                let habitInfo = NSAttributedString(string: habitText, attributes: habitAttributes)
                habitInfo.draw(at: CGPoint(x: 72, y: yPosition))
                yPosition += 60
            }
        }
        
        // Сохраняем PDF
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "HabitTracker_Report_\(Date().timeIntervalSince1970).pdf"
        let filePath = documentsPath.appendingPathComponent(filename)
        
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            Logger.export.error("Ошибка сохранения PDF: \(error.localizedDescription)")
            return nil
        }
    }
}

