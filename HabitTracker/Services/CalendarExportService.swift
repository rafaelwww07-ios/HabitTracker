//
//  CalendarExportService.swift
//  HabitTracker
//
//  Сервис для экспорта в календарь
//

import Foundation
import EventKit
import UIKit
import os.log

class CalendarExportService {
    static let shared = CalendarExportService()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    /// Экспортировать выполнения в календарь iOS
    func exportToCalendar(habit: Habit, completion: @escaping (Bool, String?) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    completion(false, "Доступ к календарю не предоставлен")
                }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            // Создаем календарь для привычек
            let calendar = self.getOrCreateCalendar(name: "HabitTracker: \(habit.name)")
            
            guard let calendar = calendar else {
                DispatchQueue.main.async {
                    completion(false, "Не удалось создать календарь")
                }
                return
            }
            
            var eventsCreated = 0
            var errors: [String] = []
            
            for completion in habit.completions {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = "✅ \(habit.name)"
                event.calendar = calendar
                event.startDate = completion.completedAt
                event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: completion.completedAt) ?? completion.completedAt
                event.notes = completion.notes
                event.isAllDay = false
                
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                    eventsCreated += 1
                } catch {
                    errors.append(error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async {
                if eventsCreated > 0 {
                    let message = errors.isEmpty ? nil : "Создано \(eventsCreated) событий. Ошибок: \(errors.count)"
                    completion(true, message)
                } else {
                    completion(false, errors.first ?? "Не удалось создать события")
                }
            }
        }
    }
    
    private func getOrCreateCalendar(name: String) -> EKCalendar? {
        // Ищем существующий календарь
        let calendars = eventStore.calendars(for: .event)
        if let existingCalendar = calendars.first(where: { $0.title == name }) {
            return existingCalendar
        }
        
        // Создаем новый календарь
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = name
        calendar.cgColor = UIColor.systemBlue.cgColor
        
        // Ищем источник iCloud или Local
        let sources = eventStore.sources
        if let iCloudSource = sources.first(where: { $0.sourceType == .calDAV && $0.title == "iCloud" }) {
            calendar.source = iCloudSource
        } else if let localSource = sources.first(where: { $0.sourceType == .local }) {
            calendar.source = localSource
        } else {
            return nil
        }
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            return calendar
        } catch {
            Logger.export.error("Ошибка создания календаря: \(error.localizedDescription)")
            return nil
        }
    }
}

