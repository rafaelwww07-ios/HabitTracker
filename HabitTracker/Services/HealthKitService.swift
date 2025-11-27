//
//  HealthKitService.swift
//  HabitTracker
//
//  Сервис интеграции с HealthKit
//

import Foundation
import HealthKit
import os.log

class HealthKitService {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private var isAuthorized = false
    
    private init() {}
    
    /// Запросить разрешение на доступ к HealthKit
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if let error = error {
                    Logger.general.error("HealthKit authorization error: \(error.localizedDescription)")
                }
                continuation.resume(returning: success)
            }
        }
    }
    
    /// Получить количество шагов за сегодня
    func getTodaySteps() async -> Double? {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else {
            return nil
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    Logger.general.error("Error fetching steps: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let steps = sum.doubleValue(for: HKUnit.count())
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Получить активные калории за сегодня
    func getTodayActiveCalories() async -> Double? {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else {
            return nil
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    Logger.general.error("Error fetching calories: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                continuation.resume(returning: calories)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Проверить доступность HealthKit
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
}

