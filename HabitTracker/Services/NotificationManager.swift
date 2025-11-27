//
//  NotificationManager.swift
//  HabitTracker
//
//  Менеджер для управления уведомлениями-напоминаниями
//

import Foundation
import UserNotifications
import os.log

protocol NotificationManagerProtocol {
    func requestAuthorization() async -> Bool
    func scheduleNotifications(for habit: Habit) async
    func removeNotifications(for habitId: UUID) async
    func removeAllNotifications() async
}

class NotificationManager: NotificationManagerProtocol {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Запросить разрешение на уведомления
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            Logger.notifications.error("Ошибка запроса разрешения на уведомления: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Запланировать уведомления для привычки
    func scheduleNotifications(for habit: Habit) async {
        // Сначала удаляем старые уведомления для этой привычки
        await removeNotifications(for: habit.id)
        
        guard let reminder = habit.reminders.first, reminder.isEnabled else {
            return
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.time)
        
        guard let hour = components.hour, let minute = components.minute else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Время для привычки! 🔔"
        content.body = "Не забудь выполнить: \(habit.name)"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.userInfo = ["habitId": habit.id.uuidString]
        
        // Создаем триггеры для каждого дня недели
        for dayOfWeek in reminder.daysOfWeek {
            var dateComponents = DateComponents()
            dateComponents.weekday = dayOfWeek
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "\(habit.id.uuidString)-\(dayOfWeek)"
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                Logger.notifications.error("Ошибка создания уведомления: \(error.localizedDescription)")
            }
        }
    }
    
    /// Удалить уведомления для конкретной привычки
    func removeNotifications(for habitId: UUID) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        
        let identifiersToRemove = pendingRequests
            .filter { $0.identifier.hasPrefix(habitId.uuidString) }
            .map { $0.identifier }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
    
    /// Удалить все уведомления
    func removeAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

/// Расширение для работы с днями недели
extension Calendar {
    /// День недели в формате 1-7 (воскресенье = 1, понедельник = 2, ..., суббота = 7)
    func weekdayComponent(from date: Date) -> Int {
        let weekday = component(.weekday, from: date)
        // Swift Calendar: воскресенье = 1, понедельник = 2, ..., суббота = 7
        // Это совпадает с нашими требованиями
        return weekday
    }
}

