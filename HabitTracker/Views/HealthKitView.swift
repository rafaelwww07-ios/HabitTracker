//
//  HealthKitView.swift
//  HabitTracker
//
//  Экран интеграции с HealthKit
//

import SwiftUI
import HealthKit

struct HealthKitView: View {
    @State private var isAuthorized = false
    @State private var todaySteps: Double?
    @State private var todayCalories: Double?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            List {
                if !HealthKitService.shared.isAvailable {
                    Section {
                        Text("HealthKit недоступен на этом устройстве")
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Статус авторизации
                    Section {
                        HStack {
                            Text("Статус")
                            Spacer()
                            if isAuthorized {
                                Label("Авторизован", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Label("Не авторизован", systemImage: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if !isAuthorized {
                            Button(action: {
                                requestAuthorization()
                            }) {
                                Text("Запросить доступ")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // Данные HealthKit
                    if isAuthorized {
                        Section("Данные за сегодня") {
                            if isLoading {
                                HStack {
                                    ProgressView()
                                    Text("Загрузка...")
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                if let steps = todaySteps {
                                    HStack {
                                        Image(systemName: "figure.walk")
                                            .foregroundColor(.blue)
                                        Text("Шаги")
                                        Spacer()
                                        Text("\(Int(steps))")
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                if let calories = todayCalories {
                                    HStack {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                        Text("Активные калории")
                                        Spacer()
                                        Text("\(Int(calories)) ккал")
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                Button(action: {
                                    loadHealthKitData()
                                }) {
                                    Text("Обновить данные")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("HealthKit")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkAuthorization()
                if HealthKitService.shared.isAvailable {
                    loadHealthKitData()
                }
            }
        }
    }
    
    private func checkAuthorization() {
        // Упрощенная проверка - в реальном приложении нужно проверять реальный статус
        isAuthorized = true
    }
    
    private func requestAuthorization() {
        isLoading = true
        Task {
            let authorized = await HealthKitService.shared.requestAuthorization()
            await MainActor.run {
                isAuthorized = authorized
                isLoading = false
                if authorized {
                    loadHealthKitData()
                }
            }
        }
    }
    
    private func loadHealthKitData() {
        guard isAuthorized else { return }
        
        isLoading = true
        
        Task {
            async let steps = HealthKitService.shared.getTodaySteps()
            async let calories = HealthKitService.shared.getTodayActiveCalories()
            
            let (stepsValue, caloriesValue) = await (steps, calories)
            
            await MainActor.run {
                todaySteps = stepsValue
                todayCalories = caloriesValue
                isLoading = false
            }
        }
    }
}

#Preview {
    HealthKitView()
}




