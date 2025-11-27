//
//  HabitGroupService.swift
//  HabitTracker
//
//  Сервис для управления группами привычек
//

import Foundation

class HabitGroupService {
    static let shared = HabitGroupService()
    
    private let userDefaults = UserDefaults.standard
    private let groupsKey = "habitGroups"
    
    private init() {}
    
    /// Получить все группы
    func getAllGroups() -> [HabitGroup] {
        guard let data = userDefaults.data(forKey: groupsKey),
              let groups = try? JSONDecoder().decode([HabitGroup].self, from: data) else {
            return []
        }
        return groups
    }
    
    /// Сохранить группы
    func saveGroups(_ groups: [HabitGroup]) {
        if let data = try? JSONEncoder().encode(groups) {
            userDefaults.set(data, forKey: groupsKey)
        }
    }
    
    /// Создать группу
    func createGroup(_ group: HabitGroup) {
        var groups = getAllGroups()
        groups.append(group)
        saveGroups(groups)
    }
    
    /// Удалить группу
    func deleteGroup(_ groupId: UUID) {
        var groups = getAllGroups()
        groups.removeAll { $0.id == groupId }
        saveGroups(groups)
    }
    
    /// Обновить группу
    func updateGroup(_ group: HabitGroup) {
        var groups = getAllGroups()
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
            saveGroups(groups)
        }
    }
    
    /// Добавить привычку в группу
    func addHabitToGroup(habitId: UUID, groupId: UUID) {
        var groups = getAllGroups()
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            if !groups[index].habitIds.contains(habitId) {
                groups[index].habitIds.append(habitId)
                saveGroups(groups)
            }
        }
    }
    
    /// Удалить привычку из группы
    func removeHabitFromGroup(habitId: UUID, groupId: UUID) {
        var groups = getAllGroups()
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].habitIds.removeAll { $0 == habitId }
            saveGroups(groups)
        }
    }
}

