//
//  ShareService.swift
//  HabitTracker
//
//  Сервис для шаринга достижений и статистики
//

import Foundation
import SwiftUI
import UIKit

class ShareService {
    static let shared = ShareService()
    
    private init() {}
    
    /// Создать текст для шаринга достижения
    func createAchievementShareText(achievement: Achievement, habitName: String?) -> String {
        let name = habitName ?? "привычка"
        var text = "🎉 Достижение разблокировано!\n\n"
        text += "\(achievement.type.title)\n"
        text += "\(achievement.type.description)\n"
        if let habitName = habitName {
            text += "\nПривычка: \(habitName)\n"
        }
        if let value = achievement.value {
            text += "Значение: \(value)\n"
        }
        text += "\n#HabitTracker #Достижения"
        return text
    }
    
    /// Создать изображение для шаринга статистики
    func createStatisticsImage(habits: [Habit]) -> UIImage? {
        // В реальном приложении можно создать красивый UIImage со статистикой
        // Здесь упрощенная версия
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600))
        
        return renderer.image { context in
            let bgColor = UIColor.systemBackground
            bgColor.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 600))
            
            // Рисуем текст статистики
            let text = "📊 Статистика привычек\n\nВсего привычек: \(habits.count)\nВсего выполнений: \(habits.reduce(0) { $0 + $1.completions.count })\n"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            text.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
        }
    }
    
    /// Показать системный UI для шаринга
    func share(items: [Any], from viewController: UIViewController?, sourceView: UIView? = nil) {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView?.bounds ?? .zero
        }
        
        if let viewController = viewController {
            viewController.present(activityVC, animated: true)
        } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}




