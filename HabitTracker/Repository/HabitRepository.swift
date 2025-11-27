//
//  HabitRepository.swift
//  HabitTracker
//
//  Repository для работы с привычками (Core Data)
//

import Foundation
import CoreData

protocol HabitRepositoryProtocol {
    func fetchAll() async throws -> [Habit]
    func fetch(by id: UUID) async throws -> Habit?
    func save(_ habit: Habit) async throws
    func delete(_ habit: Habit) async throws
    func toggleCompletion(for habitId: UUID, date: Date) async throws
    func getCompletions(for habitId: UUID, from startDate: Date, to endDate: Date) async throws -> [HabitCompletion]
}

class HabitRepository: HabitRepositoryProtocol {
    private let persistenceController: PersistenceController
    internal var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    /// Получить все привычки
    func fetchAll() async throws -> [Habit] {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
                request.predicate = NSPredicate(format: "isArchived == NO")
                request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.createdAt, ascending: false)]
                
                do {
                    let entities = try self.context.fetch(request)
                    let habits = entities.map { $0.toDomain() }
                    continuation.resume(returning: habits)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Получить привычку по ID
    func fetch(by id: UUID) async throws -> Habit? {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    let entities = try self.context.fetch(request)
                    let habit = entities.first?.toDomain()
                    continuation.resume(returning: habit)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Сохранить привычку
    func save(_ habit: Habit) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    let existingEntity = try self.context.fetch(request).first
                    if let entity = existingEntity {
                        entity.update(from: habit, context: self.context)
                    } else {
                        let entity = HabitEntity(context: self.context)
                        entity.update(from: habit, context: self.context)
                    }
                    
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Удалить привычку
    func delete(_ habit: Habit) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    if let entity = try self.context.fetch(request).first {
                        self.context.delete(entity)
                        try self.context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Переключить выполнение привычки на дату
    func toggleCompletion(for habitId: UUID, date: Date) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            context.perform {
                do {
                    // Получаем привычку
                    let habitRequest: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
                    habitRequest.predicate = NSPredicate(format: "id == %@", habitId as CVarArg)
                    habitRequest.fetchLimit = 1
                    
                    guard let habitEntity = try self.context.fetch(habitRequest).first else {
                        continuation.resume(throwing: RepositoryError.habitNotFound)
                        return
                    }
                    
                    // Проверяем существующее выполнение на эту дату
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
                    
                    let existingCompletions = try self.context.fetch(completionRequest)
                    
                    if existingCompletions.isEmpty {
                        // Создаем новое выполнение
                        let completion = HabitCompletionEntity(context: self.context)
                        completion.id = UUID()
                        completion.completedAt = startOfDay
                        completion.habit = habitEntity
                    } else {
                        // Удаляем существующее выполнение
                        existingCompletions.forEach { self.context.delete($0) }
                    }
                    
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Получить выполнения в диапазоне дат
    func getCompletions(for habitId: UUID, from startDate: Date, to endDate: Date) async throws -> [HabitCompletion] {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<HabitCompletionEntity> = HabitCompletionEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "habit.id == %@ AND completedAt >= %@ AND completedAt <= %@",
                    habitId as CVarArg,
                    startDate as NSDate,
                    endDate as NSDate
                )
                request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitCompletionEntity.completedAt, ascending: true)]
                
                do {
                    let entities = try self.context.fetch(request)
                    let completions = entities.map { $0.toDomain(habitId: habitId) }
                    continuation.resume(returning: completions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum RepositoryError: LocalizedError {
    case habitNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .habitNotFound:
            return "Привычка не найдена"
        case .invalidData:
            return "Некорректные данные"
        }
    }
}

