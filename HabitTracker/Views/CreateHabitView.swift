//
//  CreateHabitView.swift
//  HabitTracker
//
//  Экран создания и редактирования привычки
//

import SwiftUI

struct CreateHabitView: View {
    @StateObject var viewModel: CreateHabitViewModel
    let onSave: (Habit) -> Void
    let onCancel: () -> Void
    
    @State private var selectedColorIndex = 0
    @State private var selectedIconIndex = 0
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                // Основная информация
                Section("Основная информация") {
                    TextField("Название привычки", text: $viewModel.name)
                        .focused($isNameFocused)
                        .onAppear {
                            isNameFocused = true
                        }
                    
                    TextField("Описание (необязательно)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Категория", selection: $viewModel.selectedCategory) {
                        Text("Без категории").tag(nil as HabitCategory?)
                        ForEach(HabitCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category as HabitCategory?)
                        }
                    }
                }
                
                // Внешний вид
                Section("Внешний вид") {
                    // Выбор цвета
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Цвет")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                            ForEach(Array(viewModel.availableColors.enumerated()), id: \.offset) { index, color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(viewModel.selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        viewModel.selectedColor = color
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Выбор иконки
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Иконка")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(Array(viewModel.availableIcons.enumerated()), id: \.offset) { index, iconName in
                                Image(systemName: iconName)
                                    .font(.title2)
                                    .foregroundColor(viewModel.selectedIcon == iconName ? viewModel.selectedColor : .secondary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(viewModel.selectedIcon == iconName ? viewModel.selectedColor.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.selectedIcon == iconName ? viewModel.selectedColor : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        viewModel.selectedIcon = iconName
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Цель
                Section("Цель") {
                    Picker("Тип цели", selection: $viewModel.goalType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    
                    Stepper(
                        value: $viewModel.goalValue,
                        in: 1...365,
                        step: 1
                    ) {
                        HStack {
                            Text("Целевое значение:")
                            Spacer()
                            Text("\(viewModel.goalValue)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Напоминания
                Section("Напоминания") {
                    Toggle("Включить напоминания", isOn: $viewModel.isReminderEnabled)
                    
                    if viewModel.isReminderEnabled {
                        DatePicker("Время", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                        
                        DaysOfWeekPicker(selectedDays: $viewModel.reminderDays)
                    }
                }
            }
            .navigationTitle(viewModel.existingHabit == nil ? "Новая привычка" : "Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let habit = viewModel.saveHabit()
                        onSave(habit)
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

// MARK: - Days of Week Picker

struct DaysOfWeekPicker: View {
    @Binding var selectedDays: Set<Int>
    
    private let dayNames = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
    private let dayNumbers = [1, 2, 3, 4, 5, 6, 7]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(zip(dayNumbers, dayNames)), id: \.0) { dayNumber, dayName in
                Button(action: {
                    if selectedDays.contains(dayNumber) {
                        selectedDays.remove(dayNumber)
                    } else {
                        selectedDays.insert(dayNumber)
                    }
                }) {
                    Text(dayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedDays.contains(dayNumber) ? .white : .primary)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(selectedDays.contains(dayNumber) ? Color.blue : Color(.systemGray5))
                        )
                }
            }
        }
    }
}

#Preview {
    CreateHabitView(
        viewModel: CreateHabitViewModel(),
        onSave: { _ in },
        onCancel: { }
    )
}

