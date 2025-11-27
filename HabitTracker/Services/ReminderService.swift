//
//  ReminderService.swift
//  HabitTracker
//
//  Расширенный сервис напоминаний (множественные)
//

import Foundation
import UserNotifications
import os.log

class ReminderService {
    static let shared = ReminderService()
    
    private init() {}
    
    /// Создать множественные напоминания для привычки
    func createMultipleReminders(
        for habit: Habit,
        times: [Date],
        daysOfWeek: Set<Int>
    ) async {
        // Удаляем старые напоминания
        await NotificationManager.shared.removeNotifications(for: habit.id)
        
        let calendar = Calendar.current
        
        for time in times {
            let components = calendar.dateComponents([.hour, .minute], from: time)
            
            guard let hour = components.hour, let minute = components.minute else {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Время для привычки! 🔔"
            content.body = "Не забудь выполнить: \(habit.name)"
            content.sound = .default
            content.userInfo = ["habitId": habit.id.uuidString]
            
            // Создаем триггеры для каждого дня недели
            for dayOfWeek in daysOfWeek {
                var dateComponents = DateComponents()
                dateComponents.weekday = dayOfWeek
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "\(habit.id.uuidString)-\(dayOfWeek)-\(hour)-\(minute)"
                
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )
                
                do {
                    try await UNUserNotificationCenter.current().add(request)
                } catch {
                    Logger.notifications.error("Ошибка создания напоминания: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Получить все напоминания для привычки
    func getReminders(for habitId: UUID) async -> [UNNotificationRequest] {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        
        return pendingRequests.filter { request in
            request.identifier.hasPrefix(habitId.uuidString)
        }
    }
}

