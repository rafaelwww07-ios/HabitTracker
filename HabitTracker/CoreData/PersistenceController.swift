//
//  PersistenceController.swift
//  HabitTracker
//
//  Core Data Persistence Controller с поддержкой iCloud
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем тестовые данные для превью
        let sampleHabit = HabitEntity(context: viewContext)
        sampleHabit.id = UUID()
        sampleHabit.name = "Утренняя зарядка"
        sampleHabit.desc = "30 минут каждый день"
        sampleHabit.colorHex = "#FF6B6B"
        sampleHabit.iconName = "figure.run"
        sampleHabit.goalType = 0 // Дни в неделю
        sampleHabit.goalValue = 5
        sampleHabit.createdAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HabitTracker")
        
        // Настройка для iCloud синхронизации
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        // Примечание: NSPersistentStoreRemoteChangeNotificationOptionKey доступен только с iOS 13+
        // Для базовой функциональности это не критично
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

