//
//  UserProgress.swift
//  HabitTracker
//
//  Модель прогресса пользователя и геймификация
//

import Foundation

struct UserProgress {
    var totalPoints: Int = 0
    var currentLevel: Int = 1
    var pointsToNextLevel: Int = 100
    var totalDaysTracked: Int = 0
    var totalCompletions: Int = 0
    var longestStreak: Int = 0
    var badgesEarned: Set<String> = []
    
    var levelProgress: Double {
        guard pointsToNextLevel > 0 else { return 1.0 }
        let pointsInCurrentLevel = totalPoints % 100
        return Double(pointsInCurrentLevel) / Double(pointsToNextLevel)
    }
    
    mutating func addPoints(_ points: Int) {
        totalPoints += points
        updateLevel()
    }
    
    private mutating func updateLevel() {
        let newLevel = (totalPoints / 100) + 1
        if newLevel > currentLevel {
            currentLevel = newLevel
            pointsToNextLevel = 100
        } else {
            pointsToNextLevel = 100 - (totalPoints % 100)
        }
    }
    
    mutating func updateStats(daysTracked: Int, completions: Int, streak: Int) {
        totalDaysTracked = daysTracked
        totalCompletions = completions
        longestStreak = max(longestStreak, streak)
    }
}

extension UserProgress: Codable {}

enum PointsReward: Int {
    case dailyCompletion = 10
    case weeklyCompletion = 50
    case streakDay = 5
    case streakWeek = 100
    case streakMonth = 500
    case achievement = 200
    case perfectWeek = 150
}

