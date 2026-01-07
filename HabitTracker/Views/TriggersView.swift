//
//  TriggersView.swift
//  HabitTracker
//
//  Управление триггерами привычек
//

import SwiftUI

struct TriggersView: View {
    @State private var triggers: [HabitTrigger] = []
    let habits: [Habit]
    @State private var showCreateTrigger = false
    
    var body: some View {
        NavigationView {
            List {
                if triggers.isEmpty {
                    ContentUnavailableView(
                        "Нет триггеров",
                        systemImage: "bolt.slash",
                        description: Text("Создайте триггер, чтобы автоматически напоминать о связанных привычках")
                    )
                } else {
                    ForEach(triggers) { trigger in
                        TriggerRowView(trigger: trigger, habits: habits)
                    }
                    .onDelete(perform: deleteTriggers)
                }
            }
            .navigationTitle("Триггеры")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateTrigger = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                loadTriggers()
            }
            .sheet(isPresented: $showCreateTrigger) {
                CreateTriggerView(habits: habits, onSave: { trigger in
                    TriggerService.shared.createTrigger(trigger)
                    loadTriggers()
                })
            }
        }
    }
    
    private func loadTriggers() {
        triggers = TriggerService.shared.getAllTriggers()
    }
    
    private func deleteTriggers(offsets: IndexSet) {
        offsets.forEach { index in
            TriggerService.shared.deleteTrigger(triggers[index].id)
        }
        loadTriggers()
    }
}

struct TriggerRowView: View {
    let trigger: HabitTrigger
    let habits: [Habit]
    
    var triggerHabit: Habit? {
        habits.first { $0.id == trigger.triggerHabitId }
    }
    
    var targetHabit: Habit? {
        habits.first { $0.id == trigger.targetHabitId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let triggerHabit = triggerHabit {
                    Image(systemName: triggerHabit.iconName)
                        .foregroundColor(triggerHabit.color)
                }
                
                Text(triggerHabit?.name ?? "Неизвестная привычка")
                    .font(.headline)
                
                Spacer()
                
                if !trigger.isEnabled {
                    Image(systemName: "pause.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(trigger.condition.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if let targetHabit = targetHabit {
                    Image(systemName: targetHabit.iconName)
                        .foregroundColor(targetHabit.color)
                }
                
                Text(targetHabit?.name ?? "Неизвестная привычка")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CreateTriggerView: View {
    let habits: [Habit]
    let onSave: (HabitTrigger) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTriggerHabit: UUID?
    @State private var selectedTargetHabit: UUID?
    @State private var selectedCondition: TriggerCondition = .completed
    
    var body: some View {
        NavigationView {
            Form {
                Section("Привычка-триггер") {
                    Picker("Выберите привычку", selection: $selectedTriggerHabit) {
                        Text("Не выбрано").tag(nil as UUID?)
                        ForEach(habits) { habit in
                            HStack {
                                Image(systemName: habit.iconName)
                                    .foregroundColor(habit.color)
                                Text(habit.name)
                            }
                            .tag(habit.id as UUID?)
                        }
                    }
                }
                
                Section("Условие") {
                    Picker("Условие", selection: $selectedCondition) {
                        ForEach(TriggerCondition.allCases, id: \.self) { condition in
                            Text(condition.description).tag(condition)
                        }
                    }
                }
                
                Section("Целевая привычка") {
                    Picker("Выберите привычку", selection: $selectedTargetHabit) {
                        Text("Не выбрано").tag(nil as UUID?)
                        ForEach(habits) { habit in
                            HStack {
                                Image(systemName: habit.iconName)
                                    .foregroundColor(habit.color)
                                Text(habit.name)
                            }
                            .tag(habit.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("Новый триггер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        guard let triggerHabitId = selectedTriggerHabit,
                              let targetHabitId = selectedTargetHabit else {
                            return
                        }
                        
                        let trigger = HabitTrigger(
                            triggerHabitId: triggerHabitId,
                            targetHabitId: targetHabitId,
                            condition: selectedCondition
                        )
                        onSave(trigger)
                        dismiss()
                    }
                    .disabled(selectedTriggerHabit == nil || selectedTargetHabit == nil)
                }
            }
        }
    }
}

#Preview {
    TriggersView(habits: [])
}




