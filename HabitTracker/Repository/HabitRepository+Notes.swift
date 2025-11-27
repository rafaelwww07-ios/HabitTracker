//
//  HabitRepository+Notes.swift
//  HabitTracker
//
//  Расширение Repository для работы с примечаниями
//

import Foundation
import CoreData

extension HabitRepository {
    /// Обновить примечания к выполнению
    func updateCompletionNotes(for habitId: UUID, date: Date, notes: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            context.perform {
                do {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: date)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    
                    let completionRequest: NSFetchRequest<HabitCompletionEntity> = HabitCompletionEntity.fetchRequest()
                    completionRequest.predicate = NSPredicate(
                        format: "habit.id == %@ AND completedAt >= %@ AND completedAt < %@",
                        habitId as CVarArg,
                        startOfDay as NSDate,
                        endOfDay as NSDate
                    )
                    completionRequest.fetchLimit = 1
                    
                    if let completion = try self.context.fetch(completionRequest).first {
                        completion.notes = notes.isEmpty ? nil : notes
                        try self.context.save()
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: RepositoryError.habitNotFound)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

