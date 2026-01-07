//
//  CreateHabitView.swift
//  HabitTracker
//
//  Screen for creating and editing habits
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
                // Basic information
                Section("Basic Information") {
                    TextField("Habit name", text: $viewModel.name)
                        .focused($isNameFocused)
                        .onAppear {
                            isNameFocused = true
                        }
                    
                    TextField("Description (optional)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("No category").tag(nil as HabitCategory?)
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
                
                // Appearance
                Section("Appearance") {
                    // Color selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
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
                    
                    // Icon selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
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
                
                // Goal
                Section("Goal") {
                    Picker("Goal type", selection: $viewModel.goalType) {
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
                            Text("Target value:")
                            Spacer()
                            Text("\(viewModel.goalValue)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Reminders
                Section("Reminders") {
                    Toggle("Enable reminders", isOn: $viewModel.isReminderEnabled)
                    
                    if viewModel.isReminderEnabled {
                        DatePicker("Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                        
                        DaysOfWeekPicker(selectedDays: $viewModel.reminderDays)
                    }
                }
            }
            .navigationTitle(viewModel.existingHabit == nil ? "New Habit" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
    
    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
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

