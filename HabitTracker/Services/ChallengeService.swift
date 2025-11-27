//
//  ChallengeService.swift
//  HabitTracker
//
//  Сервис управления челленджами
//

import Foundation

class ChallengeService {
    static let shared = ChallengeService()
    
    private let userDefaults = UserDefaults.standard
    private let challengesKey = "challenges"
    
    private init() {}
    
    /// Получить все челленджи
    func getAllChallenges() -> [Challenge] {
        guard let data = userDefaults.data(forKey: challengesKey),
              let challenges = try? JSONDecoder().decode([Challenge].self, from: data) else {
            return []
        }
        return challenges
    }
    
    /// Сохранить челленджи
    func saveChallenges(_ challenges: [Challenge]) {
        if let data = try? JSONEncoder().encode(challenges) {
            userDefaults.set(data, forKey: challengesKey)
        }
    }
    
    /// Создать челлендж из шаблона
    func createChallenge(from template: ChallengeTemplate, habitIds: [UUID]) -> Challenge {
        Challenge(
            name: template.rawValue,
            description: template.description,
            duration: template.duration,
            habitIds: habitIds,
            startDate: Date()
        )
    }
    
    /// Обновить прогресс челленджа
    func updateChallengeProgress(_ challengeId: UUID, completedDayId: UUID) {
        var challenges = getAllChallenges()
        if let index = challenges.firstIndex(where: { $0.id == challengeId }) {
            var challenge = challenges[index]
            if !challenge.completions.contains(completedDayId) {
                challenge.completions.append(completedDayId)
                
                // Обновляем текущий день
                let calendar = Calendar.current
                let daysSinceStart = calendar.dateComponents([.day], from: challenge.startDate, to: Date()).day ?? 0
                challenge.currentDay = min(daysSinceStart + 1, challenge.duration)
                
                // Проверяем завершение
                if challenge.completions.count >= challenge.duration {
                    challenge.isCompleted = true
                    challenge.isActive = false
                }
                
                challenges[index] = challenge
                saveChallenges(challenges)
            }
        }
    }
    
    /// Получить активные челленджи
    func getActiveChallenges() -> [Challenge] {
        getAllChallenges().filter { $0.isActive && !$0.isCompleted }
    }
    
    /// Получить завершенные челленджи
    func getCompletedChallenges() -> [Challenge] {
        getAllChallenges().filter { $0.isCompleted }
    }
}
