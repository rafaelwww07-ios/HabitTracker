//
//  GroupsView.swift
//  HabitTracker
//
//  Управление группами привычек
//

import SwiftUI

struct GroupsView: View {
    let allHabits: [Habit]
    @State private var groups: [HabitGroup] = []
    @State private var showCreateGroup = false
    @State private var selectedGroup: HabitGroup?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groups) { group in
                    NavigationLink(destination: GroupDetailView(group: group, habits: allHabits)) {
                        GroupRowView(group: group, habitCount: group.habitIds.count)
                    }
                }
                .onDelete(perform: deleteGroups)
            }
            .navigationTitle("Группы привычек")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateGroup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                loadGroups()
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView(habits: allHabits, onSave: { group in
                    HabitGroupService.shared.createGroup(group)
                    loadGroups()
                })
            }
        }
    }
    
    private func loadGroups() {
        groups = HabitGroupService.shared.getAllGroups()
    }
    
    private func deleteGroups(offsets: IndexSet) {
        offsets.forEach { index in
            HabitGroupService.shared.deleteGroup(groups[index].id)
        }
        loadGroups()
    }
}

struct GroupRowView: View {
    let group: HabitGroup
    let habitCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: group.iconName)
                .font(.title2)
                .foregroundColor(group.color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(group.color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                if !group.description.isEmpty {
                    Text(group.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text("\(habitCount) привычек")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct CreateGroupView: View {
    let habits: [Habit]
    let onSave: (HabitGroup) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor = "#007AFF"
    @State private var selectedIcon = "folder.fill"
    @State private var selectedHabits: Set<UUID> = []
    
    let colors = ["#007AFF", "#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#5AC8FA", "#AF52DE", "#FF2D55"]
    let icons = ["folder.fill", "star.fill", "heart.fill", "flame.fill", "bolt.fill", "leaf.fill", "moon.fill", "sun.max.fill"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Название") {
                    TextField("Название группы", text: $name)
                    TextField("Описание (опционально)", text: $description)
                }
                
                Section("Внешний вид") {
                    Picker("Цвет", selection: $selectedColor) {
                        ForEach(colors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(Color(hex: color) ?? .blue)
                                    .frame(width: 20, height: 20)
                                Text(color)
                            }
                            .tag(color)
                        }
                    }
                    
                    Picker("Иконка", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon)
                            }
                            .tag(icon)
                        }
                    }
                }
                
                Section("Привычки") {
                    ForEach(habits) { habit in
                        Toggle(isOn: Binding(
                            get: { selectedHabits.contains(habit.id) },
                            set: { isOn in
                                if isOn {
                                    selectedHabits.insert(habit.id)
                                } else {
                                    selectedHabits.remove(habit.id)
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: habit.iconName)
                                    .foregroundColor(habit.color)
                                Text(habit.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новая группа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let group = HabitGroup(
                            name: name,
                            description: description,
                            colorHex: selectedColor,
                            iconName: selectedIcon,
                            habitIds: Array(selectedHabits)
                        )
                        onSave(group)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct GroupDetailView: View {
    let group: HabitGroup
    let habits: [Habit]
    @Environment(\.dismiss) var dismiss
    
    var groupHabits: [Habit] {
        habits.filter { group.habitIds.contains($0.id) }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(groupHabits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        HStack {
                            Image(systemName: habit.iconName)
                                .foregroundColor(habit.color)
                            Text(habit.name)
                        }
                    }
                }
            } header: {
                Text("Привычки в группе (\(groupHabits.count))")
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    GroupsView(allHabits: [])
}

